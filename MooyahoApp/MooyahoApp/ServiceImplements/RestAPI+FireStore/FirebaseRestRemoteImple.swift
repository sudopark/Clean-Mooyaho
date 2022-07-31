//
//  FirebaseRestRemoteImple.swift
//  MooyahoApp
//
//  Created by sudo.park on 2022/07/16.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import Remote
import FirebaseService
import FirebaseFirestore

import Extensions


final class FirebaseRestRemoteImple: RestRemote {
    
    private var fireStore: Firestore?
    
    private func collectionRef(_ endpoint: RestAPIEndpoint) throws -> (Firestore, CollectionReference) {
        guard let store = self.fireStore
        else {
            throw RuntimeError("firestore not setup")
        }
        
        guard let lastPath = endpoint.path.lastPathComponent
        else {
            throw RuntimeError("invalid endpoint: \(endpoint)")
        }
        
        return (store, store.collection(lastPath))
    }
}


// MARK: - find

extension FirebaseRestRemoteImple {
    
    
    func requestFind<J>(_ endpoint: RestAPIEndpoint, byID: String) async throws -> J where J : JsonMappable {
        
        let (_, collectionRef) = try self.collectionRef(endpoint)
        let docRef = collectionRef.document(byID)
        guard let object: J = try await docRef.object()
        else {
            throw RuntimeError("object not exists: \(endpoint), id: \(byID)")
        }
        return object
    }
    
    func requestFind<J>(_ endpoint: RestAPIEndpoint, byQuery: LoadQuery) async throws -> [J] where J : JsonMappable {
        
        let (_, collectionRef) = try self.collectionRef(endpoint)
        let queryConverter = FirebaseQueryConverter(collectionRef: collectionRef)
        let query = try queryConverter.convert(byQuery)
        return try await query.objects()
    }
}


// MARK: - save

extension FirebaseRestRemoteImple {
    
    func requestSave<J>(_ endpoint: RestAPIEndpoint, _ entities: [String : Any]) async throws -> J where J : JsonMappable {
        
        let id = entities[J.identifierKey] as? String
        let (_, collectionRef) = try self.collectionRef(endpoint)
        let document = id.map { collectionRef.document($0) } ?? collectionRef.document()
        return try await document.saveNew(entities)
    }
    
    func requestBatchSaves(_ endpoint: RestAPIEndpoint, _ entities: [[String : Any]]) async throws {
        let (db, collectionRef) = try self.collectionRef(endpoint)
        return try await withCheckedThrowingContinuation { continuation in
            let batch = db.batch()
            
            entities.forEach { entity in
                let docRef = collectionRef.document()
                docRef.setData(entity)
            }
            
            batch.commit { error in
                let result: Result<Void, Error> = error.map { .failure($0) } ?? .success(())
                continuation.resume(with: result)
            }
        }
    }
    
    func requestBatchUpdates(_ endpoint: RestAPIEndpoint, _ entities: [JsonPresentable]) async throws {
        
        let (db, collectionRef) = try self.collectionRef(endpoint)
        return try await withCheckedThrowingContinuation { continuation in
            let batch = db.batch()
        
            let shouldMerge = endpoint.method == .patch
            entities.forEach { entity in
                let (id, json) = (entity.identifier, entity.asJson())
                let docRef = collectionRef.document(id)
                docRef.setData(json, merge: shouldMerge)
            }
            
            batch.commit { error in
                let result: Result<Void, Error> = error.map { .failure($0) } ?? .success(())
                continuation.resume(with: result)
            }
        }
    }
    
    func requestUpdate<J>(_ endpoint: RestAPIEndpoint, id: String, to: [String : Any]) async throws -> J where J : JsonMappable {
     
        let (_, collectionRef) = try self.collectionRef(endpoint)
        let docRef = collectionRef.document(id)
        try await docRef.update(to)
        guard let object: J = try await docRef.object() else {
            throw RuntimeError("update fail: object not exists: \(endpoint), id: \(id)")
        }
        return object
    }
}


// MARK: - delete

extension FirebaseRestRemoteImple {
    
    func requestDelete(_ endpoint: RestAPIEndpoint, byId: String) async throws {
        
        let (_, collectionRef) = try self.collectionRef(endpoint)
        let docRef = collectionRef.document(byId)
        return try await docRef.delete()
    }
    
    func requestDelete(_ endpoint: RestAPIEndpoint, byQuery: MatcingQuery) async throws {
        
        let (_, collectionRef) = try self.collectionRef(endpoint)
        let queryConverter = FirebaseQueryConverter(collectionRef: collectionRef)
        let query = try queryConverter.convert(byQuery)
        
        let documents = try await query.documents()
        documents.forEach {
            let docRef = collectionRef.document($0.documentID)
            docRef.delete()
        }
    }
}


private extension String {
    
    var lastPathComponent: String? {
        return self.components(separatedBy: "/").last
    }
}

private extension DocumentReference {
    
    func object<J: JsonMappable>() async throws -> J? {
        return try await withCheckedThrowingContinuation { continuation in
            self.getDocument { snapShot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let document = snapShot, document.exists, let json = document.data()
                else {
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let object = try J.init(json: json)
                    continuation.resume(returning: object)
                } catch {
                    let error = RuntimeError("mapping fail for: \(J.self) and reason: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func saveNew<J: JsonMappable>(_ json: [String: Any]) async throws -> J {
        return try await withCheckedThrowingContinuation { continuation in
            let docID = self.documentID
            self.setData(json) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let newJson = json.merging([J.identifierKey: docID]) { $1 }
                do {
                    let object = try J.init(json: newJson)
                    continuation.resume(returning: object)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func update(_ json: [String: Any], withMerging: Bool = true) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.setData(json, merge: withMerging) { error in
                let result: Result<Void, Error> = error.map { .failure($0) } ?? .success(())
                continuation.resume(with: result)
            }
        }
    }
    
    func delete() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.delete { error in
                let result: Result<Void, Error> = error.map { .failure($0) } ?? .success(())
                continuation.resume(with: result)
            }
        }
    }
}


private extension Query {
    
    func documents() async throws -> [QueryDocumentSnapshot] {
        return try await withCheckedThrowingContinuation { continuation in
            self.getDocuments { snapshots, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let documents = snapshots?.documents ?? []
                continuation.resume(returning: documents)
            }
        }
    }
    
    func objects<J: JsonMappable>() async throws -> [J] {
        let jsons = try await self.documents().map { $0.data() }
        return jsons.compactMap { try? J.init(json: $0) }
    }
}

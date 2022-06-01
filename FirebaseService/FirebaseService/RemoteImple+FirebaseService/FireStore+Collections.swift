//
//  FireStore+Collections.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation

import RxSwift
import FirebaseFirestore

import DataStore

enum FireStoreCollectionType: String {
    case member = "members"
    case userDevice = "userdevice"
    case readCollection
    case readLinks
    case readCollectionCustomOrders
    case itemCategory
    case suggestCategoryIndexes = "indexes_category"
    case suggestReadItemIndexes = "indexes_readitem"
    case linkMemo
    case sharedInbox = "shared_inboxes"
    case sharingCollectionIndex = "sharing_collect_indexes"
    case memberFavoriteItems
    case withdrawalQueue = "withdrawal_queue"
    case feedback
}


extension Firestore {
    
    func collection(_ type: FireStoreCollectionType) -> CollectionReference {
        return self.collection(type.rawValue)
    }
}


public protocol FirebaseRemote: AuthRemote, MemberRemote, MessagingRemote,
                                ReadItemRemote, ReadItemOptionsRemote,
                                ItemCategoryRemote, ReadLinkMemoRemote, BatchUploadRemote, ShareItemRemote,
                                HelpRemote { }

extension FirebaseServiceImple: FirebaseRemote{ }


extension FirebaseServiceImple {
    
    func save(_ model: DocumentMappable,
              at collectionType: FireStoreCollectionType,
              merging: Bool = true) -> Maybe<Void> {
        
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let (docuID, json) = model.asDocument()
            let documentRef = db.collection(collectionType).document(docuID)
            documentRef.setData(json, merge: merging) { error in
                if let error = error {
                    let type = String(describing: type(of: model))
                    let remoteError = RemoteErrors.saveFail(type, reason: error)
                    callback(.error(remoteError))
                } else {
                    callback(.success(()))
                }
            }

            return Disposables.create()
        }
    }
    
    func saveNew<D: DocumentMappable>(_ json: JSON,
                                      at collectionType: FireStoreCollectionType) -> Maybe<D> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            let documentRef = db.collection(collectionType).document()
            let docuID = documentRef.documentID
            documentRef.setData(json) { error in
                
                guard error == nil else {
                    let type = String(describing: D.self)
                    let remoteError = RemoteErrors.saveFail(type, reason: error)
                    callback(.error(remoteError))
                    return
                }
                
                guard let model = D.init(docuID: docuID, json: json) else {
                    let type = String(describing: D.self)
                    let remoteError = RemoteErrors.mappingFail(type)
                    callback(.error(remoteError))
                    return
                }
                
                callback(.success(model))
            }
            return Disposables.create()
        }
    }
    
    func saveNew<D: DocumentMappable>(_ form: JSONMappable,
                                      at collectionType: FireStoreCollectionType) -> Maybe<D> {
        
        let json = form.asJSON()
        return self.saveNew(json, at: collectionType)
    }
    
    func update(docuID: String,
                newFields: [String: Any],
                at collectionType: FireStoreCollectionType) -> Maybe<Void> {
        
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let documentRef = db.collection(collectionType).document(docuID)
            documentRef.setData(newFields, merge: true) { error in
                
                guard error == nil else {
                    let type = collectionType.rawValue
                    let remoteError = RemoteErrors.updateFail(type, reason: error)
                    callback(.error(remoteError))
                    return
                }
                
                callback(.success(()))
            }
            
            return Disposables.create()
        }
    }
    
    func batch(_ collectionType: FireStoreCollectionType,
               write: @escaping (CollectionReference) -> Void) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let batch = db.batch()
            let collectionRef = db.collection(collectionType)
            write(collectionRef)
            
            batch.commit { error in
                if let error = error {
                    callback(.error(error))
                } else {
                    callback(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func load<T: DocumentMappable>(docuID: String,
                                   in collectionType: FireStoreCollectionType) -> Maybe<T?> {
        
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            let documentRef = db.collection(collectionType).document(docuID)
            documentRef.getDocument { snapShot, error in
                
                guard error == nil else {
                    let type = String(describing: T.self)
                    let remoteError = RemoteErrors.loadFail(type, reason: error)
                    callback(.error(remoteError))
                    return
                }
                
                guard let document = snapShot, document.exists, let json = document.data() else {
                    callback(.success(nil))
                    return
                }
                
                guard let model = T.init(docuID: document.documentID, json: json) else {
                    let type = String(describing: T.self)
                    let remoteError = RemoteErrors.mappingFail(type)
                    callback(.error(remoteError))
                    return
                }
                
                callback(.success(model))
            }
            return Disposables.create()
        }
    }
    
    func load<T: DocumentMappable>(query: Query) -> Maybe<[T]> {
        
        return Maybe.create {  callback in
            query.getDocuments { snapShot, error in
                guard error == nil else {
                    let type = String(describing: T.self)
                    let remoteError = RemoteErrors.loadFail(type, reason: error)
                    callback(.error(remoteError))
                    return
                }
                
                let models = snapShot?.documents.compactMap { document -> T? in
                    return T.init(docuID: document.documentID, json: document.data())
                }
                callback(.success(models ?? []))
            }
            return Disposables.create()
        }
    }
    
    func loadAllAtOnce<T: DocumentMappable>(queries: [Query]) -> Maybe<[T]> {
        
        return self.loadAll(queries: queries)
            .toArray()
            .map{ $0.flatMap{ $0 } }
            .asMaybe()
    }
    
    func loadAll<T: DocumentMappable>(queries: [Query]) -> Observable<[T]> {
        let seed: Observable<[T]> = .empty()
        let eachLoadings = queries.map{ query -> Maybe<[T]> in
            return self.load(query: query)
        }
        return eachLoadings.reduce(seed) { acc, next in
            return acc.asObservable().concat(next.asObservable())
        }
    }
    
    func delete(_ docuID: String, at collectionType: FireStoreCollectionType) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            let collectionRef = db.collection(collectionType)
            
            collectionRef.document(docuID).delete { error in
                if let error = error {
                    callback(.error(error))
                } else {
                    callback(.success(()))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAll(_ query: Query, at collectionType: FireStoreCollectionType) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            query.getDocuments { snapShot, error in
                guard error == nil else {
                    let remoteError = RemoteErrors.operationFail(error)
                    callback(.error(remoteError))
                    return
                }
                snapShot?.documents.forEach {
                    let docuRef = db.collection(collectionType).document($0.documentID)
                    docuRef.delete()
                }
                
                callback(.success(()))
            }
            return Disposables.create()
        }
    }
}

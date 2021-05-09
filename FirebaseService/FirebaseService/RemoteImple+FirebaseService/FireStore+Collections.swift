//
//  FireStore+Collections.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation

import RxSwift

import DataStore

enum FireStoreCollectionType: String {
    case member = "members"
    case userLocation = "userlocations"
    case placeSnippet = "placesnpts"
    case place = "places"
}


extension Firestore {
    
    func collection(_ type: FireStoreCollectionType) -> CollectionReference {
        return self.collection(type.rawValue)
    }
}


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
}

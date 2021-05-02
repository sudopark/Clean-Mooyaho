//
//  Remote+Auth.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation

import RxSwift

import DataStore


// MARK: - signIn

extension FirebaseServiceImple: AuthRemote {
    
    public func requestSignInAnonymously() -> Maybe<Void> {
        return Maybe.create { callback in
            Auth.auth().signInAnonymously { result, error in
                guard error == nil, let _ = result else {
                    callback(.error(RemoteErrors.operationFail(error)))
                    return
                }
                callback(.success(()))
            }
            return Disposables.create()
        }
    }
    
    public func requestSignIn(withEmail email: String, password: String) -> Maybe<DataModels.Member> {
        
        let andPostAction: (FirebaseAuth.User) -> Maybe<DataModels.Member> = { [weak self] user in
            return self?.signInPostAction(user: user) ?? .empty()
        }
        return self.signIn(withEmail: email, password: password)
            .flatMap(andPostAction)
    }
    
    private func signIn(withEmail email: String, password: String) -> Maybe<FirebaseAuth.User> {
        return Maybe.create { callback in
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                guard error == nil, let user = result?.user else {
                    callback(.error(RemoteErrors.secretSignInFail(error)))
                    return
                }
                callback(.success(user))
            }
            
            return Disposables.create()
        }
    }
    
    public func requestSignIn(using credential: ReqParams.OAuthCredential) -> Maybe<DataModels.Member> {
        
        let andPostAction: (FirebaseAuth.User) -> Maybe<DataModels.Member> = { [weak self] user in
            return self?.signInPostAction(user: user) ?? .empty()
        }
        return self.selectSignInMethod(by: credential)
            .flatMap(andPostAction)
    }
    
    private func selectSignInMethod(by credential: ReqParams.OAuthCredential) -> Maybe<FirebaseAuth.User> {
        return .empty()
    }
}


// MARK: - signin post action

extension FirebaseServiceImple {
    
    private func signInPostAction(user: FirebaseAuth.User) -> Maybe<DataModels.Member> {
        
        let loadExistingMember = self.requestLoadExistingMember(for: user)
        
        let thenSaveNewMemberIfNeed: (DataModels.Member?) -> Maybe<DataModels.Member>
        thenSaveNewMemberIfNeed = { [weak self] existingMember in
            guard let self = self else { return .empty() }
            if let member = existingMember {
                return .just(member)
            } else {
                return self.requestSaveNewMember(user.uid)
            }
        }
        
        return loadExistingMember
            .flatMap(thenSaveNewMemberIfNeed)
    }
    private func requestLoadExistingMember(for user: FirebaseAuth.User) -> Maybe<DataModels.Member?> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let documentID = user.uid
            let documentRef = db.collection(.member).document(documentID)
            documentRef.getDocument { snapShot, error in
                guard error == nil, let snapShot = snapShot, let json = snapShot.data() else {
                    let remoteError = RemoteErrors.loadFail("Member", reason: error)
                    callback(.error(remoteError))
                    return
                }
                let member = DataModels.Member(docuID: snapShot.documentID, json: json)
                callback(.success(member))
            }
            
            return Disposables.create()
        }
    }
    
    private func requestSaveNewMember(_ memberID: String) -> Maybe<DataModels.Member> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let documentRef = db.collection(.member).document(memberID)
            documentRef.setData([:]) { error in
                if let error = error {
                    callback(.error(RemoteErrors.saveFail("Member", reason: error)))
                } else {
                    let newMember = DataModels.Member(uid: memberID)
                    callback(.success(newMember))
                }
            }
            return Disposables.create()
        }
    }
}

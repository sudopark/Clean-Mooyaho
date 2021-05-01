//
//  Remote+Auth.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation

import RxSwift

import Domain
import DataStore


// MARK: - signIn

extension FirebaseServiceImple: AuthRemote {
    
    public func requestSignIn(using credential: Credential) -> Maybe<Member> {
        
        typealias FindResult = (id: String, member: Member?)
        
        let firstSignInAuth = self.selectSignInMethod(by: credential)
        
        let thenLoadExistingMember: (FirebaseAuth.User) -> Maybe<FindResult>
        thenLoadExistingMember = { [weak self] user in
            guard let self = self else { return .empty() }
            return self.requestLoadExistingMember(for: user).map{ FindResult(user.uid, $0) }
        }
        
        let thenSaveNewMemberIfNeed: (FindResult) -> Maybe<Member>
        thenSaveNewMemberIfNeed = { [weak self] result in
            guard let self = self else { return .empty() }
            if let member = result.member {
                return .just(member)
            } else {
                return self.requestSaveNewMember(result.id)
            }
        }
        
        return firstSignInAuth
            .flatMap(thenLoadExistingMember)
            .flatMap(thenSaveNewMemberIfNeed)
    }
    
    private func selectSignInMethod(by credential: Credential) -> Maybe<FirebaseAuth.User> {
        guard let emailForm = credential as? EmailBaseCredential else {
            let description = String(describing: type(of: credential))
            return .error(RemoteErrors.notSupportCredential(description))
        }
        return self.signIn(withEmail: emailForm.email, password: emailForm.password)
    }
    
    private func signIn(withEmail email: String, password: String) -> Maybe<FirebaseAuth.User> {
        return Maybe.create { callback in
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                guard error == nil, let user = result?.user else {
                    callback(.error(AuthErrors.signInError(error)))
                    return
                }
                callback(.success(user))
            }
            
            return Disposables.create()
        }
    }
    
    private func requestLoadExistingMember(for user: FirebaseAuth.User) -> Maybe<Member?> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let documentID = user.uid
            let documentRef = db.collection(.member).document(documentID)
            documentRef.getDocument { snapShot, error in
                guard error == nil, let snapShot = snapShot else {
                    let remoteError = RemoteErrors.loadFail("Member", reason: error)
                    callback(.error(remoteError))
                    return
                }
                
                guard let member = snapShot.asMember() else {
                    callback(.error(RemoteErrors.mappingFail("Member")))
                    return
                }
                
                callback(.success(member))
            }
            
            return Disposables.create()
        }
    }
    
    private func requestSaveNewMember(_ memberID: String) -> Maybe<Member> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            
            let documentRef = db.collection(.member).document(memberID)
            documentRef.setData([:]) { error in
                if let error = error {
                    callback(.error(RemoteErrors.saveFail("Member", reason: error)))
                } else {
                    let newMember = Customer(memberID: memberID)
                    callback(.success(newMember))
                }
            }
            return Disposables.create()
        }
    }
}

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
        // TODO: 소셩 로그인 타입에 따라 분기
        return .empty()
    }
}


// MARK: - signin post action

extension FirebaseServiceImple {
    
    private func signInPostAction(user: FirebaseAuth.User) -> Maybe<DataModels.Member> {
        
        let loadExistingMember: Maybe<DataModels.Member?> = self.load(docuID: user.uid, in: .member)
        
        let thenSaveNewMemberIfNeed: (DataModels.Member?) -> Maybe<DataModels.Member>
        thenSaveNewMemberIfNeed = { [weak self] existingMember in
            guard let self = self else { return .empty() }
            if let member = existingMember {
                return .just(member)
            } else {
                let newMember = DataModels.Member(uid: user.uid)
                return self.save(newMember, at: .member)
                    .map{ _ in newMember }
            }
        }
        
        return loadExistingMember
            .flatMap(thenSaveNewMemberIfNeed)
    }
}

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

extension FirebaseServiceImple {
    
    public func requestSignInAnonymously() -> Maybe<Domain.Auth> {
        return Maybe.create { callback in
            Auth.auth().signInAnonymously { result, error in
                guard error == nil, let userID = result?.user.uid else {
                    callback(.error(RemoteErrors.operationFail(error)))
                    return
                }
                callback(.success(.init(userID: userID)))
            }
            return Disposables.create()
        }
    }
    
    public func requestSignIn(withEmail email: String,
                              password: String) -> Maybe<SigninResult> {
        
        let signIn: () -> Maybe<User> = { [weak self] in
            return self?.signIn(withEmail: email, password: password) ?? .empty()
        }
        
        let andPostAction: (FirebaseAuth.User) -> Maybe<SigninResult> = { [weak self] user in
            return self?.signInPostAction(user: user) ?? .empty()
        }
        return signInPreAction()
            .flatMap(signIn)
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
    
    public func requestSignIn(using credential: Domain.OAuthCredential) -> Maybe<SigninResult> {
        
        let signIn: () -> Maybe<User> = { [weak self] in
            return self?.selectSignInMethod(by: credential) ?? .empty()
        }
        
        let andPostAction: (FirebaseAuth.User) -> Maybe<SigninResult> = { [weak self] user in
            return self?.signInPostAction(user: user) ?? .empty()
        }
        return self.signInPreAction()
            .flatMap(signIn)
            .flatMap(andPostAction)
    }
    
    private func selectSignInMethod(by credential: Domain.OAuthCredential) -> Maybe<FirebaseAuth.User> {
        
        // TODO: 소셩 로그인 타입에 따라 분기
        switch credential {
        case let customToken as CustomTokenCredential:
            return self.signinWithCustomTokenCredential(customToken)
            
        default:
            return .error(RemoteErrors.notSupportCredential(String(describing: credential)))
        }
    }
    
    private func signinWithCustomTokenCredential(_ credential: CustomTokenCredential) -> Maybe<FirebaseAuth.User> {
        
        return Maybe.create { callback in
            
            Auth.auth().signIn(withCustomToken: credential.token) { result, error in
                guard error == nil, let user = result?.user else {
                    callback(.error(RemoteErrors.credentialSigninFail(error)))
                    return
                }
                callback(.success(user))
            }
            return Disposables.create()
        }
    }
}


// MARK: - signin pre/post action

extension FirebaseServiceImple {
    
    private func signInPreAction() -> Maybe<Void> {
        guard let user = Auth.auth().currentUser else { return .just() }
        return user.isAnonymous ? self.deleteAnonymousUser(user) : self.signOut()
    }
    
    private func signInPostAction(user: FirebaseAuth.User) -> Maybe<SigninResult> {
        
        let loadExistingMember: Maybe<Member?> = self.load(docuID: user.uid, in: .member)
        
        let thenSaveNewMemberIfNeed: (Member?) -> Maybe<Member>
        thenSaveNewMemberIfNeed = { [weak self] existingMember in
            guard let self = self else { return .empty() }
            if let member = existingMember {
                return .just(member)
            } else {
                let newMember = Member(uid: user.uid)
                return self.save(newMember, at: .member)
                    .map{ _ in newMember }
            }
        }
        
        let transformAsResult: (Member) -> SigninResult = { member in
            return .init(auth: Auth(userID: member.uid), member: member)
        }
 
        return loadExistingMember
            .flatMap(thenSaveNewMemberIfNeed)
            .map(transformAsResult)
    }
    
    private func deleteAnonymousUser(_ user: FirebaseAuth.User) -> Maybe<Void> {
        return Maybe.create { callback in
            user.delete { error in
                guard error == nil else {
                    callback(.error(RemoteErrors.deleteAccountFail(error)))
                    return
                }
                callback(.success(()))
            }
            return Disposables.create()
        }
    }
    
    private func signOut() -> Maybe<Void> {
        return Maybe.create { callback in
            do {
                try Auth.auth().signOut()
                callback(.success(()))
            } catch let error {
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
}

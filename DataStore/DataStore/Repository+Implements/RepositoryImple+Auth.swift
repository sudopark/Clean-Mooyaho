//
//  AuthRepositoryImple.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol AuthRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var remote: Remote { get }
    var local: Local { get }
}


extension AuthRepository where Self: AuthRepositoryDefImpleDependency {
    
    public func fetchLastSignInMember() -> Maybe<Member?> {
        
        let preparePermissionIfNeed: (Member?) -> Void = { [weak self] member in
            member.whenNotExists {
                self?.signInAnonymouslyForPrepareDataAcessPermission()
            }
        }
        
        return self.local.fetchCurrentMember()
            .do(onNext: preparePermissionIfNeed)
    }
    
    private func signInAnonymouslyForPrepareDataAcessPermission() {
        self.remote.requestSignInAnonymously()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestSignIn(using secret: EmailBaseSecret) -> Maybe<Member> {
        let signing = self.remote.requestSignIn(withEmail: secret.email, password: secret.password)
        return self.requestSignInAndSaveMemberInfo(signing)
    }
    
    public func requestSignIn(using credential: OAuthCredential) -> Maybe<Member> {
        
        let signing = self.remote.requestSignIn(using: credential.toParameter())
        return self.requestSignInAndSaveMemberInfo(signing)
    }
    
    private func requestSignInAndSaveMemberInfo(_ signingAction: Maybe<DataModels.Member>) -> Maybe<Member> {
        let andSaveMemberInfo: (Member) -> Void = { [weak self] member in
            guard let self = self else { return }
            self.local.saveSignedIn(member: member)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        return signingAction
            .map(Member.init(model:))
            .do(onNext: andSaveMemberInfo)
    }
}


// TOOD: 구현 및 공통로직 추출 필요
extension OAuthCredential {
    
    func toParameter() -> ReqParams.OAuthCredential {
        return .init()
    }
}

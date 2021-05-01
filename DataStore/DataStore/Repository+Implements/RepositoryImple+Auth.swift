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
        // TODO:
        return .empty()
    }
    
    public func signIn(using credential: Credential) -> Maybe<Member> {
        
        let requestSignIn = self.remote.requestSignIn(using: credential)
        let andSaveMemberInfo: (Member) -> Void = { [weak self] member in
            guard let self = self else { return }
            self.local.saveSignedIn(member: member)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return requestSignIn
            .do(onNext: andSaveMemberInfo)
    }
}

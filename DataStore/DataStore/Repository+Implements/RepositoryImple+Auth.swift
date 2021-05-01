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


public protocol AuthRepositoryDefImpleDependency {
    
    var remote: Remote { get }
    var local: Local { get }
}


extension AuthRepository where Self: AuthRepositoryDefImpleDependency {
    
    public func fetchLastSignInMember() -> Maybe<Member?> {
        return .empty()
    }
    
    public func signIn(using credential: Credential) -> Maybe<Member> {
        return .empty()
    }
}

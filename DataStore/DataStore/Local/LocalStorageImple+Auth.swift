//
//  LocalStorageImple+Auth.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchCurrentAuth() -> Maybe<Auth?> {
        return .just(nil)
    }
    
    public func fetchCurrentMember() -> Maybe<Member?> {
        return .just(nil)
    }
    
    public func saveSignedIn(auth: Auth) -> Maybe<Void> {
        return .just()
    }
    
    public func saveSignedIn(member: Member) -> Maybe<Void> {
        return .just()
    }
}

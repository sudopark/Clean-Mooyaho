//
//  Local.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol Local: AuthLocal { }


public protocol AuthLocal {

    func fetchCurrentMember() -> Maybe<Member?>
    func saveSignedIn(member: Member) -> Maybe<Void>
}


public class FakeLocal: Local {
    
    public func fetchCurrentMember() -> Maybe<Member?> {
        return .empty()
    }
    
    public func saveSignedIn(member: Member) -> Maybe<Void> {
        return .empty()
    }
}

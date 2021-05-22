//
//  RepositoryImple+Member.swift
//  DataStore
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol MemberRepositoryDefImpleDependency {
    
    var memberRemote: MemberRemote { get }
    
}



// MARK: - member repository default implementation

extension MemberRepository where Self: MemberRepositoryDefImpleDependency {
    
    
    public func requestUpdateUserPresence(_ userID: String, isOnline: Bool) -> Maybe<Void> {
        return self.memberRemote.requestUpdateUserPresence(userID, isOnline: isOnline)
    }
    
    public func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        // TODO: implement needs
        return .empty()
    }
}

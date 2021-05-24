//
//  StubMemberUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/05/25.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class StubMemberUsecase: MemberUsecase, Stubbable {
    
    public init() {}
    
    public func updateUserIsOnline(_ userID: String, isOnline: Bool) {
        self.verify(key: "updateUserIsOnline", with: isOnline)
    }
    
    public func loadCurrentMembership() -> Maybe<MemberShip> {
        return self.resolve(key: "loadCurrentMembership") ?? .empty()
    }
}


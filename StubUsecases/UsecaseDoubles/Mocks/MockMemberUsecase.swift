//
//  MockMemberUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/05/25.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class MockMemberUsecase: MemberUsecase, Mocking {
    
    public init() {}
    
    public func updateUserIsOnline(_ userID: String, deviceID: String, isOnline: Bool) {
        self.verify(key: "updateUserIsOnline", with: isOnline)
    }
    
    public func updatePushToken(_ userID: String, deviceID: String, newToken: String) {
        self.verify(key: "updatePushToken")
    }
    
    public func loadCurrentMembership() -> Maybe<MemberShip> {
        return self.resolve(key: "loadCurrentMembership") ?? .empty()
    }
    
    public let currentMemberSubject = PublishSubject<Member?>()
    public var currentMember: Observable<Member?> {
        return currentMemberSubject.asObservable()
    }
    
    public func fetchCurrentMember() -> Member? {
        return self.resolve(key: "fetchCurrentMember")
    }
    
    public let updateStatus = PublishSubject<UpdateMemberProfileStatus>()
    public func updateCurrent(memberID: String, updateFields: [MemberUpdateField], with profile: ImageUploadReqParams?) -> Observable<UpdateMemberProfileStatus> {
        self.verify(key: "updateCurrent")
        return self.updateStatus.asObservable()
    }
}


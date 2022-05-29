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
    public func refreshMembers(_ ids: [String]) {
        self.verify(key: "refreshMembers", with: ids)
    }
    
    public func loadMembers(_ ids: [String]) -> Maybe<[Member]> {
        self.verify(key: "loadMembers", with: ids)
        return self.resolve(key: "loadMembers") ?? .empty()
    }
    
    public func members(for ids: [String]) -> Observable<[String : Member]> {
        return self.resolve(key: "members:for") ?? .empty()
    }
    
    
    public init() {}
    
    public func updatePushToken(_ userID: String, deviceID: String, newToken: String) {
        self.verify(key: "updatePushToken")
    }
    
    public let currentMemberSubject = PublishSubject<Member?>()
    public var currentMember: Observable<Member?> {
        return currentMemberSubject.asObservable()
    }
    
    public func fetchCurrentMember() -> Member? {
        return self.resolve(key: "fetchCurrentMember")
    }
    
    public func reloadCurrentMember() -> Maybe<Member> {
        return self.resolve(key: "reloadCurrentMember") ?? .empty()
    }
    
    public let updateStatus = PublishSubject<UpdateMemberProfileStatus>()
    public func updateCurrent(memberID: String, updateFields: [MemberUpdateField], with profile: ImageUploadReqParams?) -> Observable<UpdateMemberProfileStatus> {
        self.verify(key: "updateCurrent", with: (updateFields, profile))
        return self.updateStatus.asObservable()
    }
}


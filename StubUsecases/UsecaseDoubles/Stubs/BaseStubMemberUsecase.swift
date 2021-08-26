//
//  BaseStubMemberUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/08/30.
//

import Foundation

import RxSwift

import Domain


open class BaseStubMemberUsecase: MemberUsecase {
    
    open func fetchCurrentMember() -> Member? {
        return nil
    }
    
    open func updateUserIsOnline(_ userID: String, deviceID: String, isOnline: Bool) {

    }
    
    public func updatePushToken(_ userID: String, deviceID: String, newToken: String) {
        
    }
    
    public func refreshMembers(_ ids: [String]) {
        
    }
    
    public func loadMembers(_ ids: [String]) -> Maybe<[Member]> {
        return .empty()
    }
    
    public func updateCurrent(memberID: String, updateFields: [MemberUpdateField], with profile: ImageUploadReqParams?) -> Observable<UpdateMemberProfileStatus> {
        return .empty()
    }
    
    public func loadCurrentMembership() -> Maybe<MemberShip> {
        return .empty()
    }
    
    public var currentMember: Observable<Member?> {
        return .empty()
    }
    
    public func members(for ids: [String]) -> Observable<[String : Member]> {
        return .empty()
    }
    
    
    
}

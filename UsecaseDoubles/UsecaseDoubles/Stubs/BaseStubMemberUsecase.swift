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
    
    public struct Scenario {
        
        public var members: Result<[Member], Error> = {
            let members = (0..<10).map{ Member(uid: "u:\($0)", nickName: "n:\($0)", icon: .emoji("☹️"))}
            return .success(members)
        }()
        
        public var currentMember: Member?
        
        public var loadMemberResult: Result<[Member], Error> = .success([])
        public var reloadedMember: Member?
        
        public init() { }
    }
    
    private let scenario: Scenario
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    open func fetchCurrentMember() -> Member? {
        return nil
    }
    
    public func reloadCurrentMember() -> Maybe<Member> {
        return self.scenario.reloadedMember.map { .just($0) } ?? .empty()
    }
    
    open func updateUserIsOnline(_ userID: String, deviceID: String, isOnline: Bool) {

    }
    
    public func updatePushToken(_ userID: String, deviceID: String, newToken: String) {
        
    }
    
    public func refreshMembers(_ ids: [String]) {
        
    }
    

    public func loadMembers(_ ids: [String]) -> Maybe<[Member]> {
        return self.scenario.loadMemberResult.asMaybe()
    }
    
    public func updateCurrent(memberID: String, updateFields: [MemberUpdateField], with profile: ImageUploadReqParams?) -> Observable<UpdateMemberProfileStatus> {
        return .empty()
    }
    
    public func loadCurrentMembership() -> Maybe<MemberShip> {
        return .empty()
    }
    
    public let currentMemberMocking = PublishSubject<Member?>()
    public var currentMember: Observable<Member?> {
        return self.currentMemberMocking
            .startWith(self.scenario.currentMember)
    }
    
    public func members(for ids: [String]) -> Observable<[String : Member]> {
        return self.scenario.members
            .map{ $0.reduce(into: [String: Member]()) { $0[$1.uid] = $1 } }
            .asMaybe()
            .asObservable()
    }
}

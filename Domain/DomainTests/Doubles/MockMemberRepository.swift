//
//  MockMemberRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class MockMemberRepository: MemberRepository, Mocking {
    
    func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void> {
        self.verify(key: "requestUpdateUserPresence", with: isOnline)
        return self.resolve(key: "requestUpdateUserPresence") ?? .empty()
    }
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        self.verify(key: "requestUpdatePushToken")
        return self.resolve(key: "requestUpdatePushToken") ?? .empty()
    }
    
//    func requestLoadNearbyUsers(at location: Coordinate) -> Maybe<[UserPresence]> {
//        return self.resolve(key: "requestLoadNearbyUsers") ?? .empty()
//    }
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        return self.resolve(key: "requestLoadMembership") ?? .empty()
    }
    
    let uploadStatus = PublishSubject<MemberProfileUploadStatus>()
    func requestUploadMemberProfileImage(_ memberID: String, source: ImageUploadReqParams) -> Observable<MemberProfileUploadStatus> {
        return self.uploadStatus.asObservable()
    }
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          imageSource: ImageSource?) -> Maybe<Member> {
        return self.resolve(key: "requestUpdateMemberProfileFields") ?? .empty()
    }
}

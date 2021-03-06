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
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        self.verify(key: "requestUpdatePushToken")
        return self.resolve(key: "requestUpdatePushToken") ?? .empty()
    }
    
    let uploadStatus = PublishSubject<MemberProfileUploadStatus>()
    func requestUploadMemberProfileImage(_ memberID: String, source: ImageUploadReqParams) -> Observable<MemberProfileUploadStatus> {
        return self.uploadStatus.asObservable()
    }
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member> {
        return self.resolve(key: "requestUpdateMemberProfileFields") ?? .empty()
    }
    
    func fetchMembers(_ ids: [String]) -> Maybe<[Member]> {
        return self.resolve(key: "fetchMembers") ?? .empty()
    }
    
    func requestLoadMembers(_ ids: [String]) -> Maybe<[Member]> {
        return self.resolve(key: "requestLoadMembers") ?? .empty()
    }
}

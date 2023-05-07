//
//  MemberRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public enum MemberProfileUploadStatus {
    case uploading(_ percent: Float)
    case completed(_ source: MemberThumbnail?)
}

public protocol MemberRepository: Sendable, AnyObject {
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void>
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         source: ImageUploadReqParams) -> Observable<MemberProfileUploadStatus>
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member>
    
    func fetchMembers(_ ids: [String]) -> Maybe<[Member]>
    
    func requestLoadMembers(_ ids: [String]) -> Maybe<[Member]>
}


extension MemberRepository {
    
    public func fetchMember(_ id: String) -> Maybe<Member?> {
        return self.fetchMembers([id]).map{ $0.first }
    }
    
    public func requestLoadMember(_ id: String) -> Maybe<Member?> {
        return self.requestLoadMembers([id]).map{ $0.first }
    }
}

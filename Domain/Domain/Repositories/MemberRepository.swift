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
    case completed(_ source: ImageSource?)
}

public protocol MemberRepository {
    
    func requestUpdateUserPresence(_ userID: String, isOnline: Bool) -> Maybe<Void>
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip>
    
    func requestUploadMemberProfileImage(_ memberID: String, source: MemberProfileImageSources) -> Observable<MemberProfileUploadStatus>
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          imageSource: ImageSource?) -> Maybe<Void>
}

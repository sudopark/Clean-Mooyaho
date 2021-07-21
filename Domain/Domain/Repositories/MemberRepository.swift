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

public protocol MemberRepository: AnyObject {
    
    func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void>
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void>
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip>
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         source: ImageUploadReqParams) -> Observable<MemberProfileUploadStatus>
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          imageSource: ImageSource?) -> Maybe<Member>
}

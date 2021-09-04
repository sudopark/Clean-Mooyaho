//
//  MemberInfo.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/03.
//

import Foundation

import Domain


public struct MemberInfo: Equatable {
    
    public let uid: String
    public let name: String
    public let thumbNail: Thumbnail?
    
    public init(member: Member) {
        self.uid = member.uid
        self.name = member.nickName ?? "Unknown".localized
        self.thumbNail = member.icon
    }
}

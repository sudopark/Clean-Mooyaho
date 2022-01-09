//
//  Member.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct Member {
    
    public let uid: String
    
    public var nickName: String?
    public var introduction: String?
    public var deactivatedDateTimeStamp: TimeStamp?
    
    public var isDeactivated: Bool {
        return self.deactivatedDateTimeStamp != nil
    }
    
    public var icon: MemberThumbnail?
    
    public init(uid: String, nickName: String? = nil, icon: MemberThumbnail? = nil) {
        self.uid = uid
        self.nickName = nickName
        self.icon = icon
    }
}


extension Member {
    
    public var isProfileSetup: Bool {
        return self.nickName?.isNotEmpty == true
    }
    
    public static var memberDefaultEmoji: MemberThumbnail {
        return .emoji("👻")
    }
}


// MARK: - update member params

public enum MemberUpdateField: Equatable {
    case nickName(_ newValue: String)
    case introduction(_ newValue: String?)
}

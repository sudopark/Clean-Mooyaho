//
//  AnonymousUser.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct AnonymousUser: Member {
    
    public let userID: String
    public let isAnonymous = true
    
    public init(userID: String) {
        self.userID = userID
    }
}


extension AnonymousUser {
    
    public var memberID: String { self.userID }
    
    public var realName: String? {
        get { nil }
        set { }
    }
    
    public var nickName: String? {
        get { nil }
        set { }
    }
    
    public var email: String? {
        get { nil }
        set { }
    }
    
    public var imageSource: ImageSource? {
        get { nil }
        set { }
    }
    
    public var verifiedPhoneNumber: String? {
        get { nil }
        set { }
    }
}

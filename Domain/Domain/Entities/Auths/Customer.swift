//
//  Customer.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct Customer: Member {
    
    public let memberID: String
    
    public var realName: String?
    
    public var nickName: String?
    
    public var email: String?
    
    public var imageSource: ImageSource?
    
    public var verifiedPhoneNumber: String?
    
    public init(memberID: String) {
        self.memberID = memberID
    }
}

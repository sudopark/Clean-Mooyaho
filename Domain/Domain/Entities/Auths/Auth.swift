//
//  Auth.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation



// MARK: - Auth

public struct Auth: Equatable {
    
    public let userID: String
    
    public init(userID: String) {
        self.userID = userID
    }
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.userID == rhs.userID
    }
}


// MARK: - SigninResult

public struct SigninResult {
    
    public let auth: Auth
    public let member: Member
    
    public init(auth: Auth, member: Member) {
        self.auth = auth
        self.member = member
    }
}

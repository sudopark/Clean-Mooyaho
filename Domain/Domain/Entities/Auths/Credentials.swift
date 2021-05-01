//
//  Secrets+OauthCredentials.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Secrets and Credentials

public struct EmailBaseSecret {
    
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}


// MARK: OAuthCredential protocol

public protocol OAuthCredential { }

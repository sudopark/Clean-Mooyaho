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


public struct CustomTokenCredential: OAuthCredential {
    
    public let token: String
    public init(token: String) {
        self.token = token
    }
}

public struct AppleAuthCredential: OAuthCredential {
    
    public let provider: String
    public let idToken: String
    public let nonce: String
    public var accessToken: String?
    
    public init(provider: String, idToken: String, nonce: String) {
        self.provider = provider
        self.idToken = idToken
        self.nonce = nonce
    }
}

public struct GoogleAuthCredential: OAuthCredential {
    
    public let idToken: String
    public let accessToken: String
    
    public init(idToken: String, accessToken: String) {
        self.idToken = idToken
        self.accessToken = accessToken
    }
}


// MARK: OAuthServiceProviderType

public protocol OAuthServiceProviderType {
    var uniqueIdentifier: String { get }
}

public protocol OAuthServiceProviderTypeRepresentable {
    
    var providerType: OAuthServiceProviderType { get }
}

public enum OAuthServiceProviderTypes: String, OAuthServiceProviderType {
    
    case kakao
    case apple
    case google
    
    public var uniqueIdentifier: String {
        return self.rawValue
    }
}

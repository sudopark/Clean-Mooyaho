//
//  Credentials.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Credential Protocol and EmailBaseCredential

public protocol Credential { }


public struct EmailBaseCredential: Credential {
    
    public let email: String
    public let password: String
}


// MARK: OAuth2 Credeintial protocol

public protocol OAuth2Credential: Credential { }

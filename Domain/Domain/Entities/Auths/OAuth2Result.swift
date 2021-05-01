//
//  OAuth2Result.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol OAuth2Credential {
    
    var uniqueIdentifier: String { get }
}

public protocol OAuth2AdditionalUserInfo { }

public protocol OAuth2Result {
    
    var credential: OAuth2Credential { get }
    
    var additionalInfo: OAuth2AdditionalUserInfo? { get }
    
}

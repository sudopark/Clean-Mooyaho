//
//  AuthErrors.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum AuthErrors: Error {
    
    case oauth2Fail(_ reason: Error)
}

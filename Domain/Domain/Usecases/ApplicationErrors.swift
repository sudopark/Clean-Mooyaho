//
//  ApplicationErrors.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum ApplicationErrors: Error {
    
    case unsupportSignInProvider
    case invalid
    case sigInNeed
    case profileNotSetup
    case shouldWaitPublishHooray(until: TimeStamp)
    case notFound
    case userDataMigrationFail(_ error: Error)
}

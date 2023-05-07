//
//  CrashLogger.swift
//  Domain
//
//  Created by sudo.park on 2022/01/02.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol CrashLogger {
    
    func setupUserIdentifier(_ identifier: String)
    
    func setupValue(_ value: Any, key: String)
    
    func log(_ message: String)
}

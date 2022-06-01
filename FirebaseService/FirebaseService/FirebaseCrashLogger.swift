//
//  FirebaseCrashLogger.swift
//  FirebaseService
//
//  Created by sudo.park on 2022/01/02.
//

import Foundation

import FirebaseCrashlytics

import Domain


public final class FirebaseCrashLogger: CrashLogger {
    
    public init() {}
}


extension FirebaseCrashLogger {
    
    public func setupUserIdentifier(_ identifier: String) {
        Crashlytics.crashlytics().setUserID(identifier)
    }
    
    public func setupValue(_ value: Any, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    public func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}

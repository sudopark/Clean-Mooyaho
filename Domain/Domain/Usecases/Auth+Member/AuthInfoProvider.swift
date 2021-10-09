//
//  AuthInfoProvider.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol AuthInfoProvider: AnyObject {
    
    func currentAuth() -> Auth?
    
    func signedInMemberID() -> String?
}

extension AuthInfoProvider {
    
    public func isSignedIn() -> Bool {
        return self.signedInMemberID() != nil
    }
}

public protocol AuthInfoManger: AuthInfoProvider {
    
    func updateAuth(_ newValue: Auth)
    
    func clearAuth()
}

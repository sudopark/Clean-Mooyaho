//
//  AuthInfoProvider.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol AuthInfoProvider {
    
    func currentAuth() -> Auth?
}

public protocol AuthInfoManger: AuthInfoProvider {
    
    func updateAuth(_ newValue: Auth)
    
    func clearAuth()
}


extension SharedDataStoreService {
    
    public func currentAuth() -> Auth? {
        return self.get(SharedDataKeys.auth.rawValue)
    }
    
    public func updateAuth(_ newValue: Auth) {
        self.update(SharedDataKeys.auth.rawValue, value: newValue)
    }
    
    public func clearAuth() {
        self.delete(SharedDataKeys.auth.rawValue)
    }
}

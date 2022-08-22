//
//  AuthInfoProviderV2.swift
//  Domain
//
//  Created by sudo.park on 2022/08/17.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol AuthInfoProviderV2: Sendable {

    func updateAuth(_ newValue: Auth) async
    func signInMemberID() async -> String?
}

public actor AuthInfoProviderImple: AuthInfoProviderV2 {
    
    private var auth: Auth?
    
    public init(auth: Auth? = nil) {
        self.auth = auth
    }
}


extension AuthInfoProviderImple {
    
    public func updateAuth(_ newValue: Auth) async {
        self.auth = newValue
    }
    
    public func signInMemberID() -> String? {
        return self.auth?.userID
    }
}

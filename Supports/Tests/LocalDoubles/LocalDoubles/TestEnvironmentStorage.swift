//
//  TestEnvironmentStorage.swift
//  LocalDoubles
//
//  Created by sudo.park on 2022/07/27.
//

import Foundation

import Local


extension EnvironmentStorageImple {
    
    static var testStorage: EnvironmentStorage {
        return EnvironmentStorageImple(UserDefaults.standard, keyPrefix: "test_env")
    }
}

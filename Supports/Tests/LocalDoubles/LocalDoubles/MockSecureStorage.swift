//
//  MockSecureStorage.swift
//  LocalDoubles
//
//  Created by sudo.park on 2022/07/27.
//

import Foundation

import Local
import Extensions

open class MockSecureStorage: SecureStorage {
    
    public var didSetupSharedGroupIdentifier: String?
    open func setupSharedGroup(_ identifier: String) {
        self.didSetupSharedGroupIdentifier = identifier
    }
    
    public var writeResult: Result<Void, Error>?
    open func write<V>(_ key: String, value: V) throws {
        try self.writeResult?.throwOrNot()
    }
    
    public var readResult: Result<Any, Error>?
    open func read<V>(_ key: String) throws -> V? {
        return try self.readResult?.unwrapSuccessOrThrow()
    }
    
    public var removeResult: Result<Void, Error>?
    open func remove(_ key: String) throws {
        try self.removeResult?.throwOrNot()
    }
}

//
//  MockSecureStorage.swift
//  LocalDoubles
//
//  Created by sudo.park on 2022/07/27.
//

import Foundation

import Local

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


private extension Result where Success == Void {
    
    func throwOrNot() throws {
        switch self {
        case .success: return
        case .failure(let error): throw error
        }
    }
}


private extension Result where Success == Any {
    
    func unwrapSuccessOrThrow<T>() throws -> T? {
        let resultWithType = self.map { $0 as? T }
        switch resultWithType {
        case .success(let t): return t
        case .failure(let error): throw error
        }
    }
}

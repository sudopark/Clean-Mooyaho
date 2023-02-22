//
//  BaseRepositoryUsageTests.swift
//  RepositoryTests
//
//  Created by sudo.park on 2023/02/22.
//

import XCTest
import UnitTestHelpKit

class BaseRepositoryUsageTests: BaseTestCase {
    
    func runTest(_ action: @escaping () -> Void) throws {
        try self.setUpWithError()
        action()
        try self.tearDownWithError()
    }
    
    func runAsyncTest(_ action: @Sendable @escaping () async throws -> Void) async throws {
        try self.setUpWithError()
        try await action()
        try self.tearDownWithError()
    }
}

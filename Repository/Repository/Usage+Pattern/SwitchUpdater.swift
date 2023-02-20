//
//  SwitchUpdater.swift
//  Repository
//
//  Created by sudo.park on 2023/02/21.
//

import Foundation
import Extensions


struct SwitchUpdater<MainStorage: Sendable, CacheStorage: Sendable>: Sendable {
    
    private let mainStorage: MainStorage
    private let cacheStorage: CacheStorage?
    init(mainStorage: MainStorage, cacheStorage: CacheStorage?) {
        self.mainStorage = mainStorage
        self.cacheStorage = cacheStorage
    }
    
    
    func update<T: Sendable>(
        _ updateOnMainStorage: @Sendable @escaping (MainStorage) async throws -> T,
        and updateOnCache: (@Sendable (CacheStorage, T) async throws -> T)? = nil
    ) async throws -> T {
        
        let updateResult = try await updateOnMainStorage(self.mainStorage)
        
        guard let cacheUpdate = updateOnCache
        else {
            return updateResult
        }
        
        guard let cacheStorage = self.cacheStorage
        else {
            throw RuntimeError("cache storage not exists")
        }
        
        Task.detached {
            try? await cacheUpdate(cacheStorage, updateResult)
        }
        
        return updateResult
    }
}

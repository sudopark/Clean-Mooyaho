//
//  ConcatLoader.swift
//  Repository
//
//  Created by sudo.park on 2023/02/18.
//

import Foundation
import RxSwift
import RxSwiftDoNotation
import Extensions

struct ConcatLoader<MainStorage: Sendable, CacheStorage: Sendable>: Sendable {
    
    private let mainStroage: MainStorage
    private let cacheStorage: CacheStorage?
    
    init(mainStroage: MainStorage, cacheStorage: CacheStorage?) {
        self.mainStroage = mainStroage
        self.cacheStorage = cacheStorage
    }
    
    
    func load<T>(
        _ fromCache: (@Sendable (CacheStorage) async throws -> T?)? = nil,
        fromMain: @Sendable @escaping (MainStorage) async throws -> T,
        and refreshCache: (@Sendable (CacheStorage?, T) async throws -> Void)? = nil
    ) -> Observable<T> {
        let loadFromCache: Observable<T?> = .create {
            guard let loading = fromCache
            else {
                return nil
            }
            guard let cache = self.cacheStorage
            else {
                throw RuntimeError("invalid usage: cache storage needs")
            }
            return try? await loading(cache)
        }
        let loadFromMain: Observable<T> = .create {
            try await self.loadFromMainStorageAndRefreshCacheIfNeed(fromMain, refreshCache)
        }
        return loadFromCache
            .compactMap { $0 }
            .concat(loadFromMain)
    }
    
    private func loadFromMainStorageAndRefreshCacheIfNeed<T>(
        _ load: @Sendable @escaping (MainStorage) async throws -> T,
        _ refreshing: (@Sendable (CacheStorage?, T) async throws -> Void)?
    ) async throws -> T {
        
        let data = try await load(mainStroage)
        
        if let refreshing = refreshing, let cache = cacheStorage {
            Task.detached { try? await refreshing(cache, data) }
        }
        return data
    }
}

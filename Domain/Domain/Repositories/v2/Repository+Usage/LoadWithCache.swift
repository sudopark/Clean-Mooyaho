//
//  LoadWithCache.swift
//  Domain
//
//  Created by sudo.park on 2022/08/29.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct LoadWithCache<Local: Sendable, Remote: Sendable>: Sendable {
    
    private let authInfoProvider: AuthInfoProviderV2
    private let local: Local
    private let remote: Remote
    
    public init(
        _ authInfoProvider: AuthInfoProviderV2,
        _ local: Local,
        _ remote: Remote
    ) {
        self.authInfoProvider = authInfoProvider
        self.local = local
        self.remote = remote
    }
    
    public func `do`<T: Sendable>(
        _ localFetching: @Sendable @escaping (Local) async throws -> [T],
        thenLoadFromRemote: @Sendable @escaping (Remote, String, [T]) async throws -> [T],
        andUpdateLocal: (@Sendable (Local, [T]) async throws -> Void)? = nil
    ) async throws -> [T] {
        
        let loadFromLocal = try await localFetching(self.local)
        let remoteData = try await loadFromRemoteIfNeed(localData: loadFromLocal, thenLoadFromRemote, andUpdateLocal)
        return loadFromLocal + (remoteData ?? [])
    }
    
    private func loadFromRemoteIfNeed<T: Sendable>(
        localData: [T],
        _ loadFromRemote: @Sendable @escaping (Remote, String, [T]) async throws -> [T],
        _ updateLocal: (@Sendable (Local, [T]) async throws -> Void)?
    ) async throws -> [T]? {
        
        guard let ownerID = await authInfoProvider.signInMemberID()
        else {
            return nil
        }
        
        let remoteData = try await loadFromRemote(self.remote, ownerID, localData)
        if let refreshing = updateLocal, remoteData.isNotEmpty {
            Task.detached { try await refreshing(self.local, remoteData) }
        }
        return remoteData
    }
}

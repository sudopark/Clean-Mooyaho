//
//  ConcatLoading.swift
//  Domain
//
//  Created by sudo.park on 2022/08/19.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public struct ConcatLoading<Local: Sendable, Remote: Sendable>: Sendable {
    
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
        _ loadFromCache: @Sendable @escaping (Local) async throws -> T?,
        thenRemoteIfNeed: @Sendable @escaping (Remote, String) async throws -> T?,
        andRefreshCache: (@Sendable (Local, T) async throws -> Void)? = nil
    ) -> Observable<T> {
        
        let loadFromLocal: Observable<T> = .create { try await loadFromCache(local) }
        let loadFromRemote: Observable<T> = .create {
            try await self.loadFromRemoteIfNeedAndRefreshCache(thenRemoteIfNeed, andRefreshCache)
        }
        return loadFromLocal
            .concat(loadFromRemote)
    }
    
    private func loadFromRemoteIfNeedAndRefreshCache<T: Sendable>(
        _ remoteLoading: @Sendable @escaping (Remote, String) async throws -> T?,
        _ andRefreshCache: (@Sendable (Local, T) async throws -> Void)? = nil
    ) async throws -> T? {
        
        guard let ownerID = await self.authInfoProvider.signInMemberID()
        else { return nil }
        
        let remoteData = try await remoteLoading(self.remote, ownerID)
        if let refreshing = andRefreshCache, let data = remoteData {
            Task.detached { try await refreshing(self.local, data) }
        }
        return remoteData
    }
}

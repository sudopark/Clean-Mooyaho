//
//  SwitchLoading.swift
//  Domain
//
//  Created by sudo.park on 2022/08/29.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct SwitchLoading<Local: Sendable, Remote: Sendable>: Sendable {
    
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
        _ loadFromRemote: @Sendable @escaping (Remote, String) async throws -> [T],
        andUpdateCache: (@Sendable (Local, [T]) async throws -> Void)? = nil,
        orLoadFromLocal: @Sendable @escaping (Local) async throws -> [T]
    ) async throws -> [T] {
        
        guard let ownerID = await self.authInfoProvider.signInMemberID()
        else {
            return try await orLoadFromLocal(self.local)
        }
        
        let remoteData = try await loadFromRemote(self.remote, ownerID)
        if let refreshing = andUpdateCache {
            Task.detached { try await refreshing(self.local, remoteData) }
        }
        return remoteData
    }
}

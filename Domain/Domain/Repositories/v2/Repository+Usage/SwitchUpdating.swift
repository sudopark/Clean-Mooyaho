//
//  SwitchUpdating.swift
//  Domain
//
//  Created by sudo.park on 2022/08/19.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation
import Extensions


public struct SwitchUpdating<Local: Sendable, Remote: Sendable>: Sendable {
    
    private let authInfoProvider: AuthInfoProviderV2
    private let local: Local
    private let remote: Remote
    
    public init(
        authInfoProvider: AuthInfoProviderV2,
        local: Local,
        remote: Remote
    ) {
        self.authInfoProvider = authInfoProvider
        self.local = local
        self.remote = remote
    }
    
    public func `do`<T: Sendable>(
        _ udpateOnRemote: @Sendable @escaping (Remote, String) async throws -> T,
        andUpdateCache: (@Sendable (Local, T) async throws -> Void)? = nil,
        orUpdateOnLocal: (@Sendable (Local) async throws -> T)? = nil
    ) async throws -> T {
        
        guard let ownerID = await self.authInfoProvider.signInMemberID()
        else {
            return try await self.onlyUpdateOnLocal(orUpdateOnLocal)
        }
        
        let updateList = try await udpateOnRemote(self.remote, ownerID)
        
        
        if let refreshing = andUpdateCache {
            Task.detached {
                try? await refreshing(self.local, updateList)
            }
        }
        return updateList
    }
    
    private func onlyUpdateOnLocal<T>(
        _ updating: (@Sendable (Local) async throws -> T)?
    ) async throws -> T {
        guard let updating else {
            throw RuntimeError("no ownerid but local updating is missing")
        }
        return try await updating(self.local)
    }
}

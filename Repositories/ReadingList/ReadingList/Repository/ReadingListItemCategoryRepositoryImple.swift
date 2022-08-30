//
//  ReadingListItemCategoryRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/23.
//

import Foundation

import RxSwift
import Extensions

import Domain


public final class ReadingListItemCategoryRepositoryImple: ReadingListItemCategoryRepository, Sendable {
    
    private let authInfoProvider: AuthInfoProviderV2
    private let local: ReadingListItemCategoryLocal
    private let remote: ReadingListItemCategoryRemote
    
    public init(
        authInfoProvider: AuthInfoProviderV2,
        local: ReadingListItemCategoryLocal,
        remote: ReadingListItemCategoryRemote
    ) {
        self.authInfoProvider = authInfoProvider
        self.local = local
        self.remote = remote
    }
}


// MARK: - load

extension ReadingListItemCategoryRepositoryImple {
    
    private var loadWithCache: LoadWithCache<ReadingListItemCategoryLocal, ReadingListItemCategoryRemote> {
        return .init(self.authInfoProvider, self.local, self.remote)
    }
    
    public func loadCategories(in ids: [String]) async throws -> [ReadingListItemCategory] {
        return try await self.loadWithCache
            .do { local in
                return (try? await local.loadCategories(in: ids)) ?? []
            } thenLoadFromRemote: { remote, _, categoriesFromLocal in
                let alreayLoaded = Set(categoriesFromLocal.map { $0.uid })
                let loadNeedIDs = ids.filter { !alreayLoaded.contains($0) }
                return try await remote.loadCategories(in: loadNeedIDs)
            } andUpdateLocal: { local, categories in
                try await local.saveCategories(categories)
            }
    }
    
    private var switchLoading: SwitchLoading<ReadingListItemCategoryLocal, ReadingListItemCategoryRemote> {
        return .init(self.authInfoProvider, self.local, self.remote)
    }
    
    public func loadCategories(
        earilerThan creatTime: TimeStamp,
        pageSize: Int
    ) async throws -> [ReadingListItemCategory] {
        return try await self.switchLoading
            .do { remote, ownerID in
                return try await remote.loadCategories(for: ownerID, earilerThan: creatTime, pageSize: pageSize)
            } andUpdateCache: { local, categoriesFromRemote in
                return try await local.saveCategories(categoriesFromRemote)
            } orLoadFromLocal: { local in
                return try await local.loadCategories(earilerThan: creatTime, pageSize: pageSize)
            }
    }
    
    public func findCategory(by name: String) async throws -> ReadingListItemCategory? {
        return try await self.switchLoading
            .do { remote, ownerID in
                try await remote.findCategory(for: ownerID, by: name)
            } andUpdateCache: { local, category in
                guard let category = category else { return }
                try await local.saveCategories([category])
            } orLoadFromLocal: { local in
                try await local.findCategory(by: name)
            }
    }
}


// MARK: - update

extension ReadingListItemCategoryRepositoryImple {
    
    private var switchUpdating: SwitchUpdating<ReadingListItemCategoryLocal, ReadingListItemCategoryRemote> {
        return .init(authInfoProvider: self.authInfoProvider, local: self.local, remote: self.remote)
    }
    
    public func saveCategories(_ categories: [ReadingListItemCategory]) async throws {
        return try await self.switchUpdating
            .do { remote, ownerID in
                return try await remote.saveCategories(for: ownerID, categories)
            } andUpdateCache: { local, _ in
                return try await local.saveCategories(categories)
            } orUpdateOnLocal: { local in
                return try await local.saveCategories(categories)
            }
    }
    
    public func updateCategory(_ category: ReadingListItemCategory) async throws -> ReadingListItemCategory {
        return try await self.switchUpdating
            .do { remote, ownerID in
                try await remote.updateCategory(for: ownerID, category)
            } andUpdateCache: { local, updated in
                _ = try await local.updateCategory(updated)
            } orUpdateOnLocal: { local in
                try await local.updateCategory(category)
            }
    }
    
    public func removeCategory(_ uid: String) async throws {
        return try await self.switchUpdating
            .do { remote, _ in
                try await remote.removeCategory(uid)
            } andUpdateCache: { local, _ in
                try await local.removeCategory(uid)
            } orUpdateOnLocal: { local in
                try await local.removeCategory(uid)
            }
    }
}

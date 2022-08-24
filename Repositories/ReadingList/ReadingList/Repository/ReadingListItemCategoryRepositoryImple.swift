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
    
    public func loadCategories(in ids: [String]) -> Observable<[ReadingListItemCategory]> {
        return .empty()
    }
    
    public func loadCategories(
        earilerThan creatTime: TimeStamp,
        pageSize: Int
    ) async throws -> [ReadingListItemCategory] {
        throw RuntimeError("failed")
    }
    
    public func loadCategory(by name: String) async throws -> ReadingListItemCategory {
        throw RuntimeError("failed")
    }
    
    public func loadLatestCategories() async throws -> [ReadingListItemCategory] {
        throw RuntimeError("failed")
    }
}


// MARK: - update

extension ReadingListItemCategoryRepositoryImple {
    
    public func saveCategories(_ categories: [ReadingListItemCategory]) async throws {
        throw RuntimeError("failed")
    }
    
    public func updateCategory(_ category: ReadingListItemCategory) async throws -> ReadingListItemCategory {
        throw RuntimeError("failed")
    }
    
    public func removeCategory(_ uid: String) async throws {
        throw RuntimeError("failed")
    }
}

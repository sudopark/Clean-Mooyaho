//
//  StubUserDataMigrateRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubUserDataMigrationRepository: UserDataMigrateRepository {
    
    struct Scenario {
        var isMigrationNeed: Result<Bool, Error> = .success(true)
        
        var migrationNeedItemCategoryChunks: [[ItemCategory]] = []
        
        var migrationNeedReadItemChunks: [[ReadItem]] = []
        
        var migrationNeedReadLinkMemoChunks: [[ReadLinkMemo]] = []
    }
    
    private let scenario: Scenario
    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    func checkMigrationNeed() -> Maybe<Bool> {
        return self.scenario.isMigrationNeed.asMaybe()
    }
    
    func requestMoveReadItemCategories(for userID: String) -> Infallible<[ItemCategory]> {
        return .from(self.scenario.migrationNeedItemCategoryChunks)
    }
    
    func requestMoveReadItems(for userID: String) -> Infallible<[ReadItem]> {
        return .from(self.scenario.migrationNeedReadItemChunks)
    }
    
    func requestMoveReadLinkMemos(for userID: String) -> Infallible<[ReadLinkMemo]> {
        return .from(self.scenario.migrationNeedReadLinkMemoChunks)
    }
    
    var mockCopyMember: PublishSubject<Void>?
    func copyMemberCache() -> Infallible<Void> {
        return self.mockCopyMember?.asInfallible(onErrorJustReturn: ()) ?? .just(())
    }
    
    var didCleared = false
    func clearMigrationNeedData() -> Maybe<Void> {
        self.didCleared = true
        return .just()
    }
}

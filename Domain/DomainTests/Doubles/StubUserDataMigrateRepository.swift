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
        
        var migrationError: Error?
    }
    
    private let scenario: Scenario
    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    func checkMigrationNeed() -> Maybe<Bool> {
        return self.scenario.isMigrationNeed.asMaybe()
    }
    
    func requestMoveReadItemCategories(for userID: String) -> Observable<[ItemCategory]> {
        return .from(self.scenario.migrationNeedItemCategoryChunks)
    }
    
    func requestMoveReadItems(for userID: String) -> Observable<[ReadItem]> {
        
        if let error = self.scenario.migrationError {
            return .error(error)
        }
        
        return .from(self.scenario.migrationNeedReadItemChunks)
    }
    
    func requestMoveReadLinkMemos(for userID: String) -> Observable<[ReadLinkMemo]> {
        return .from(self.scenario.migrationNeedReadLinkMemoChunks)
    }
    
    var mockClearStorage: PublishSubject<Void>?
    var didCleared = false
    func clearMigrationNeedData() -> Maybe<Void> {
        return (self.mockClearStorage?.asMaybe() ?? .just())
            .do(onNext: {
                self.didCleared = true
            })
    }
}

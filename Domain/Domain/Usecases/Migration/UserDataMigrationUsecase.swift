//
//  UserDataMigrationUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics


// MARK: - UserDataMigrationStatus

public enum UserDataMigrationStatus {
    case idle
    case migrating
    case finished
}


// MARK: - UserDataMigrationUsecase

public protocol UserDataMigrationUsecase {
    
    func startDataMigration(for userID: String)
    
    func resumeMigrationIfNeed(for userID: String)
    
    func pauseMigration()
    
    func cancelMigration()
    
    var migratedItems: Observable<[ReadItem]> { get }
    
    var status: Observable<UserDataMigrationStatus> { get }
}


// MARK: - UserDataMigrationUsecaseImple

public final class UserDataMigrationUsecaseImple: UserDataMigrationUsecase {
    
    private let migrationRepository: UserDataMigrateRepository
    public init(migrationRepository: UserDataMigrateRepository) {
        self.migrationRepository = migrationRepository
    }
    
    private struct Subjects {
        let status = BehaviorRelay<UserDataMigrationStatus>(value: .idle)
        let movedItemChunk = PublishSubject<[ReadItem]>()
    }
    
    private var disposeBag = DisposeBag()
    private let subjects = Subjects()
}


extension UserDataMigrationUsecaseImple {
    
    
    public func startDataMigration(for userID: String) {
        
        let migrateCategories = self.migrateReadItemCategoriesIfNeed(for: userID)
        
        let thenMigrateReadItems: () -> Maybe<Void> = { [weak self] in
            return self?.migrateReadItemsIfNeed(for: userID) ?? .empty()
        }
        
        let thenMigrateReadLinkMemo: () -> Maybe<Void> = { [weak self] in
            return self?.migrateReadLinkMemoIfNeed(for: userID) ?? .empty()
        }
        
        let thenCopyMemberCache: () -> Maybe<Void> = { [weak self] in
            return self?.migrateMemberCache() ?? .empty()
        }
        
        let updateStatus: () -> Void = { [weak self] in
            self?.subjects.status.accept(.finished)
        }
        
        self.subjects.status.accept(.migrating)
        migrateCategories
            .flatMap(thenMigrateReadItems)
            .flatMap(thenMigrateReadLinkMemo)
            .flatMap(thenCopyMemberCache)
            .subscribe(onSuccess: updateStatus)
            .disposed(by: self.disposeBag)
    }
    
    public func resumeMigrationIfNeed(for userID: String) {
        
        let startIfNeed: (Bool) -> Void = { [weak self] isNeed in
            guard isNeed else { return }
            self?.startDataMigration(for: userID)
        }
        self.migrationRepository
            .checkMigrationNeed()
            .subscribe(onSuccess: startIfNeed)
            .disposed(by: self.disposeBag)
    }
    
    public func pauseMigration() {
        self.disposeBag = .init()
        self.subjects.status.accept(.idle)
    }
    
    public func cancelMigration() {
        self.pauseMigration()
        self.migrationRepository.clearMigrationNeedData()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func migrateReadItemCategoriesIfNeed(for userID: String) -> Maybe<Void> {
        return self.migrationRepository
            .requestMoveReadItemCategories(for: userID)
            .asObservable()
            .reduce((), accumulator: { _, _ in () })
            .asMaybe()
    }
    
    private func migrateReadItemsIfNeed(for userID: String) -> Maybe<Void> {
        
        let readItemsMoved: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.movedItemChunk.onNext(items)
        }
        return self.migrationRepository
            .requestMoveReadItems(for: userID)
            .do(onNext: readItemsMoved)
            .asObservable()
            .reduce((), accumulator: { _, _ in () })
            .asMaybe()
    }
    
    private func migrateReadLinkMemoIfNeed(for userID: String) -> Maybe<Void> {
        return self.migrationRepository
            .requestMoveReadLinkMemos(for: userID)
            .asObservable()
            .reduce((), accumulator: { _, _ in () })
            .asMaybe()
    }
    
    private func migrateMemberCache() -> Maybe<Void> {
        return self.migrationRepository.copyMemberCache()
            .asObservable()
            .asMaybe()
    }
}


extension UserDataMigrationUsecaseImple {
    
    public var migratedItems: Observable<[ReadItem]> {
        return self.subjects.movedItemChunk.asObservable()
    }
    
    public var status: Observable<UserDataMigrationStatus> {
        return self.subjects.status.asObservable()
    }
}


//private extension Infallible {
//
//    func concatAll() -> Maybe<Void> {
//
//    }
//}

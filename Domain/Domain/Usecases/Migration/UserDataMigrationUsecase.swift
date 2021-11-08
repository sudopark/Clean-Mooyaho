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
    case fail(Error)
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
    private weak var readItemUpdateEventPublisher: PublishSubject<ReadItemUpdateEvent>?
    
    public init(migrationRepository: UserDataMigrateRepository,
                readItemUpdateEventPublisher: PublishSubject<ReadItemUpdateEvent>?) {
        
        self.migrationRepository = migrationRepository
        self.readItemUpdateEventPublisher = readItemUpdateEventPublisher
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
        
        let finalizeMigration: () -> Maybe<Void> = { [weak self] in
            return self?.migrationRepository.clearMigrationNeedData() ?? .empty()
        }
        
        let updateStatus: () -> Void = { [weak self] in
            logger.print(level: .goal, "user data migration finished!!")
            self?.subjects.status.accept(.finished)
        }
        
        let didFailMigration: (Error) -> Void = { [weak self] error in
            
            logger.print(level: .warning, "user data migration fail => \(error)")
            
            let applicationError = ApplicationErrors.userDataMigrationFail(error)
            self?.subjects.status.accept(.fail(applicationError))
        }
        
        self.subjects.status.accept(.migrating)
        logger.print(level: .info, "user data migration did start")
        migrateCategories
            .flatMap(thenMigrateReadItems)
            .flatMap(thenMigrateReadLinkMemo)
            .flatMap(finalizeMigration)
            .subscribe(onSuccess: updateStatus, onError: didFailMigration)
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
            .logMigrating("item category") { $0.count }
            .reduce((), accumulator: { _, _ in () })
            .asMaybe()
    }
    
    private func migrateReadItemsIfNeed(for userID: String) -> Maybe<Void> {
        
        let readItemsMoved: ([ReadItem]) -> Void = { [weak self] items in
            self?.subjects.movedItemChunk.onNext(items)
            items.forEach {
                self?.readItemUpdateEventPublisher?.onNext(.updated($0))
            }
        }
        return self.migrationRepository
            .requestMoveReadItems(for: userID)
            .logMigrating("read item") { $0.count }
            .do(onNext: readItemsMoved)
            .reduce((), accumulator: { _, _ in () })
            .asMaybe()
    }
    
    private func migrateReadLinkMemoIfNeed(for userID: String) -> Maybe<Void> {
        return self.migrationRepository
            .requestMoveReadLinkMemos(for: userID)
            .logMigrating("link memo") { $0.count }
            .reduce((), accumulator: { _, _ in () })
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


private extension Observable {
    
    func logMigrating(_ type: String,
                      _ counting: @escaping (Element) -> Int? = { _ in nil }) -> Observable<Element> {
        
        let onNext: (Element) -> Void = { element in
            let countText = counting(element).map { "\($0)" } ?? "nil"
            logger.print(level: .debug, "user data migration: move \(type) chunk end, count: \(countText)")
        }
        
        let onError: (Error) -> Void = { error in
            logger.print(level: .error, "user data migration fail: \(type)")
        }
        
        let onCompleted: () -> Void = {
            logger.print(level: .debug, "user data migration: move all \(type) end")
        }
        
        let onSubscribe: () -> Void = {
            logger.print(level: .debug, "user data migration: start move \(type)")
        }
        
        return self
            .do(onNext: onNext, onError: onError, onCompleted: onCompleted, onSubscribe: onSubscribe)
    }
}

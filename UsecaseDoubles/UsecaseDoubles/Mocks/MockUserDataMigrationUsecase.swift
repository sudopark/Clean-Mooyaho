//
//  MockUserDataMigrationUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/11/07.
//

import Foundation

import RxSwift

import Domain


open class MockUserDataMigrationUsecase: UserDataMigrationUsecase {
    
    public let statusMocking = BehaviorSubject<UserDataMigrationStatus>(value: .idle)
    public let migratedItemMocking = PublishSubject<[ReadItem]>()
    
    public init() {}
    
    public func startDataMigration(for userID: String) {
        self.statusMocking.onNext(.migrating)
    }
    
    public var needResume = false
    public func resumeMigrationIfNeed(for userID: String) {
        if needResume {
            self.statusMocking.onNext(.migrating)
            self.statusMocking.onNext(.finished(notStarted: false))
        } else {
            self.statusMocking.onNext(.finished(notStarted: true))
        }
    }
    
    public var didMigrationPaused = false
    public func pauseMigration() {
        self.didMigrationPaused = true
        self.statusMocking.onNext(.idle)
    }
    
    public func cancelMigration() { }
    
    public var migratedItems: Observable<[ReadItem]> {
        return self.migratedItemMocking.asObservable()
    }
     
    public var status: Observable<UserDataMigrationStatus> {
        return self.statusMocking.asObservable()
    }
}

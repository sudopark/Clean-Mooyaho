//
//  WaitMigrationViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - WaitMigrationViewModel

public enum MigrationProcessAndResult {
    case migrating
    case finished
    case fail
    
    init?(_ status: UserDataMigrationStatus) {
        switch status {
        case .migrating: self = .migrating
        case .finished: self = .finished
        case .fail: self = .fail
        default: return nil
        }
    }
}

public protocol WaitMigrationViewModel: AnyObject {

    // interactor
    func startMigration()
    func doMigrationLater()
    func confirmMigrationFinished()
    
    // presenter
    var message: Observable<(title: String, description: String)> { get }
    var migrationProcessAndResult: Observable<MigrationProcessAndResult> { get }
}


// MARK: - WaitMigrationViewModelImple

public final class WaitMigrationViewModelImple: WaitMigrationViewModel {
    
    private let userID: String
    private let migrationUsecase: UserDataMigrationUsecase
    private let router: WaitMigrationRouting
    private weak var listener: WaitMigrationSceneListenable?
    
    public init(userID: String,
                migrationUsecase: UserDataMigrationUsecase,
                router: WaitMigrationRouting,
                listener: WaitMigrationSceneListenable?) {
        
        self.userID = userID
        self.migrationUsecase = migrationUsecase
        self.router = router
        self.listener = listener
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
        let status = BehaviorSubject<UserDataMigrationStatus?>(value: nil)
        let migratedItemCount = BehaviorRelay<Int>(value: 0)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        
        let increaseMigratedItemCount: ([ReadItem]) -> Void = { [weak self] chunk in
            guard let self = self else { return }
            let newCount = self.subjects.migratedItemCount.value + chunk.count
            self.subjects.migratedItemCount.accept(newCount)
        }
        self.migrationUsecase.migratedItems
            .subscribe(onNext: increaseMigratedItemCount)
            .disposed(by: self.disposeBag)
        
        let updateStatus: (UserDataMigrationStatus) -> Void = { [weak self] status in
            self?.subjects.status.onNext(status)
            self?.checkMigrationFinishedWithEmptyItems(status)
        }
        self.migrationUsecase.status
            .subscribe(onNext: updateStatus)
            .disposed(by: self.disposeBag)
    }
    
    private func checkMigrationFinishedWithEmptyItems(_ status: UserDataMigrationStatus) {
        guard case .finished = status, self.subjects.migratedItemCount.value == 0 else { return }
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - WaitMigrationViewModelImple Interactor

extension WaitMigrationViewModelImple {
    
    public func startMigration() {
        
        self.migrationUsecase.startDataMigration(for: self.userID)
    }
    
    public func doMigrationLater() {
        
        let isMigrating = try? self.subjects.status.value()?.isMigrating
        if isMigrating == true {
            self.migrationUsecase.pauseMigration()
        }
        
        self.router.closeScene(animated: true, completed: nil)
    }
    
    public func confirmMigrationFinished() {
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - WaitMigrationViewModelImple Presenter

extension WaitMigrationViewModelImple {
    
    public var message: Observable<(title: String, description: String)> {
        
        let asResultMessage: (UserDataMigrationStatus) -> (title: String, description: String)?
        asResultMessage = { status in
            switch status {
            case .finished:
                return (
                    "Migration complete".localized,
                    "All data uploads are complete!".localized
                )
            case .fail:
                return (
                    "Migration failed".localized,
                    "Migration failed. Please try again after a while.\n(You can restart the operation from the settings screen.)".localized
                )
                
            default: return nil
            }
        }
        
        return self.subjects.status
            .compactMap { $0 }
            .compactMap(asResultMessage)
    }
    
    public var migrationProcessAndResult: Observable<MigrationProcessAndResult> {
        return self.subjects.status
            .compactMap { $0 }
            .compactMap { MigrationProcessAndResult($0) }
    }
}

private extension UserDataMigrationStatus {
    
    var isMigrating: Bool {
        guard case .migrating = self else { return false }
        return true
    }
}

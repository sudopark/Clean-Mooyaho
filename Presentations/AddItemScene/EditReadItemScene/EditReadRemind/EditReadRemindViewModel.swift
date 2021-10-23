//
//  EditReadRemindViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EditReadRemindViewModel

public protocol EditReadRemindViewModel: AnyObject {

    // interactor
    func selectDate(_ newDate: Date)
    func confirmSelectRemindTime()
    
    // presenter
    var initialDate: Observable<Date> { get }
    var isConfirmable: Observable<Bool> { get }
}


// MARK: - EditReadRemindViewModelImple

public final class EditReadRemindViewModelImple: EditReadRemindViewModel {
    
    private let editCase: EditRemindCase
    private let remindUsecase: ReadRemindUsecase
    private let router: EditReadRemindRouting
    private weak var listener: EditReadRemindSceneListenable?
    
    public init(_ editCase: EditRemindCase,
                remindUsecase: ReadRemindUsecase,
                router: EditReadRemindRouting,
                listener: EditReadRemindSceneListenable?) {
        
        self.editCase = editCase
        self.remindUsecase = remindUsecase
        self.router = router
        self.listener = listener
        
        self.setupInitialTime()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let selectedDate = BehaviorRelay<Date?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func setupInitialTime() {
        switch self.editCase {
        case let .edit(remind, _):
            self.subjects.selectedDate.accept(Date(timeIntervalSince1970: remind.scheduledTime))
            
        default:
            self.subjects.selectedDate.accept(Date())
        }
    }
}


// MARK: - EditReadRemindViewModelImple Interactor

extension EditReadRemindViewModelImple {

    public func selectDate(_ newDate: Date) {
        self.subjects.selectedDate.accept(newDate)
    }
    
    public func confirmSelectRemindTime() {
        
        guard let date = self.subjects.selectedDate.value, date.timeIntervalSince(Date()) > 0 else { return }
        
        switch self.editCase {
        case .makeNew(nil):
            self.closeSceneAndEmitEvent(date)
            
        case let .makeNew(item):
            guard let item = item else { return }
            self.updateRemindAndCloseScene(for: item, newTime: date)
            
        case let .edit(_, item):
            self.updateRemindAndCloseScene(for: item, newTime: date)
        }
    }
    
    private func closeSceneAndEmitEvent(_ newDate: Date) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.editReadRemind(didSelect: newDate)
        }
    }
    
    private func updateRemindAndCloseScene(for item: ReadItem, newTime: Date) {
        
        let handleScheduled: (ReadRemind) -> Void = { [weak self] newRemind in
            self?.router.closeScene(animated: true) {
                self?.listener?.editReadRemind(didScheduled: newRemind)
            }
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.remindUsecase
            .scheduleRemind(for: item, at: newTime.timeIntervalSince1970)
            .subscribe(onSuccess: handleScheduled, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - EditReadRemindViewModelImple Presenter

extension EditReadRemindViewModelImple {
    
    public var initialDate: Observable<Date> {
        return self.subjects.selectedDate
            .compactMap { $0 }
            .take(1)
    }
    
    public var isConfirmable: Observable<Bool> {
        return self.subjects.selectedDate
            .compactMap { $0 }
            .map { $0.timeIntervalSince(Date()) > 0 }
            .distinctUntilChanged()
    }
}

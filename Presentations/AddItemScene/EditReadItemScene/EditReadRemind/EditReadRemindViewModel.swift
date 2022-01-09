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
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - EditReadRemindViewModel

public protocol EditReadRemindViewModel: AnyObject {

    // interactor
    func checkPermission()
    func selectDate(_ newDate: Date)
    func clearSelect()
    func confirmSelectRemindTime()
    
    // presenter
    var initialDate: Observable<Date> { get }
    var isConfirmable: Observable<Bool> { get }
    var confirmButtonTitle: Observable<String> { get }
    var showClearButton: Bool { get }
    var isUpdating: Observable<Bool> { get }
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
        let isUpdating = BehaviorRelay<Bool>(value: false)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func setupInitialTime() {
        switch self.editCase {
        case let .select(startWith):
            let time = startWith.map { Date(timeIntervalSince1970: $0) }
            self.subjects.selectedDate.accept(time)
            
        case let .edit(item):
            let time = item.remindTime.map { Date(timeIntervalSince1970: $0) }
            self.subjects.selectedDate.accept(time)
        }
    }
}


// MARK: - EditReadRemindViewModelImple Interactor

extension EditReadRemindViewModelImple {
    
    public func checkPermission() {
        
        let alertPermissionNeedIfNeed: (Bool) -> Void = { [weak self] hasPermission in
            guard hasPermission == false else { return }
            self?.alertPermissionNeed()
        }
        
        self.remindUsecase.preparePermission()
            .subscribe(onSuccess: alertPermissionNeedIfNeed)
            .disposed(by: self.disposeBag)
    }
    
    private func alertPermissionNeed() {
        
        let close: () -> Void = { [weak self] in
            self?.router.closeScene(animated: true, completed: nil)
        }
        
        let moveToSetting: () -> Void = { [weak self] in
            self?.router.openAlertSetting()
        }
        
        guard let form = AlertBuilder(base: .init())
                .title("Can_t use remind service".localized)
                .message("To use remind service activate alert setting".localized)
                .confirmed(moveToSetting)
                .customConfirmText("Setting".localized)
                .canceled(close)
                .build()
        else { return }
        
        self.router.alertForConfirm(form)
    }

    public func selectDate(_ newDate: Date) {
        self.subjects.selectedDate.accept(newDate)
    }
    
    public func clearSelect() {
    
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.editReadRemind(didSelect: nil)
        }
    }
    
    public func confirmSelectRemindTime() {
        
        let date = self.subjects.selectedDate.value
        
        switch self.editCase {
        case .select:
            self.closeSceneAndEmitEvent(date)
            
        case let .edit(item):
            self.updateRemindAndCloseScene(for: item, newTime: date)
        }
    }
    
    private func closeSceneAndEmitEvent(_ newDate: Date?) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.editReadRemind(didSelect: newDate)
        }
    }
    
    private func updateRemindAndCloseScene(for item: ReadItem, newTime: Date?) {
        
        guard self.subjects.isUpdating.value == false else { return }
        
        let handleScheduled: () -> Void = { [weak self] in
            self?.subjects.isUpdating.accept(false)
            self?.router.closeScene(animated: true) {
                let newItem = item |> \.remindTime .~ newTime?.timeIntervalSince1970
                self?.listener?.editReadRemind(didUpdate: newItem)
            }
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isUpdating.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isUpdating.accept(true)
        self.remindUsecase
            .updateRemind(for: item, futureTime: newTime?.timeIntervalSince1970)
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
        let checkDate: (Date?) -> Bool = { date in
            return date.map { $0.timeIntervalSince(Date()) > 0 } ?? false
        }
        return self.subjects.selectedDate
            .map(checkDate)
            .distinctUntilChanged()
    }
    
    public var confirmButtonTitle: Observable<String> {
        let transform: (Date?) -> String = { date in
            
            let validateTimeText: (Date) -> String? = {
                $0.timeIntervalSince(Date()) > 0 ? $0.timeIntervalSince1970.remindTimeText() : nil
            }
 
            return date.flatMap(validateTimeText) ?? "Select a future time".localized
        }
        return self.subjects.selectedDate
            .map(transform)
            .distinctUntilChanged()
    }
    
    public var showClearButton: Bool {
        guard case .select = self.editCase else { return false }
        return true
    }
    
    public var isUpdating: Observable<Bool> {
        return self.subjects.isUpdating
            .distinctUntilChanged()
    }
}

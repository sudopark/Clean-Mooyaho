//
//  LinkMemoViewModel.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/24.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - LinkMemoViewModel

public protocol LinkMemoViewModel: AnyObject {

    // interactor
    func updateContent(_ text: String)
    func deleteMemo()
    func confirmSave()
    
    // presenter
    var initialText: Observable<String?> { get }
    var confirmSavable: Observable<Bool> { get }
}


// MARK: - LinkMemoViewModelImple

public final class LinkMemoViewModelImple: LinkMemoViewModel {
    
    private let memoUsecase: ReadLinkMemoUsecase
    private let router: LinkMemoRouting
    private weak var listener: LinkMemoSceneListenable?
    
    public init(memo: ReadLinkMemo,
                memoUsecase: ReadLinkMemoUsecase,
                router: LinkMemoRouting,
                listener: LinkMemoSceneListenable?) {
        
        self.memoUsecase = memoUsecase
        self.router = router
        self.listener = listener
        
        self.subjects.memo.accept(memo)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let memo = BehaviorRelay<ReadLinkMemo?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - LinkMemoViewModelImple Interactor

extension LinkMemoViewModelImple {
    
    public func updateContent(_ text: String) {
        
        guard let item = self.subjects.memo.value else { return }
        let newItem = item |> \.content .~ text
        self.subjects.memo.accept(newItem)
    }
    
    public func deleteMemo() {
        
        guard let itemID = self.subjects.memo.value?.linkItemID else { return }
        
        let deleted: () -> Void = { [weak self] in
            self?.router.closeScene(animated: true) {
                self?.listener?.linkMemo(didRemoved: itemID)
            }
        }

        self.memoUsecase
            .deleteMemo(for: itemID)
            .subscribe(onSuccess: deleted, onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    public func confirmSave() {
        
        guard let newMemo = self.subjects.memo.value else { return }
        
        let saved: () -> Void = {
            self.router.closeScene(animated: true) {
                self.listener?.linkMemo(didUpdated: newMemo)
            }
        }
        self.memoUsecase
            .updateMemo(newMemo)
            .subscribe(onSuccess: saved, onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    func handleError() -> (Error) -> Void {
        return { [weak self] error in
            self?.router.alertError(error)
        }
    }
}


// MARK: - LinkMemoViewModelImple Presenter

extension LinkMemoViewModelImple {
    
    public var initialText: Observable<String?> {
        return self.subjects.memo
            .compactMap { $0 }
            .map { $0.content }
    }
    
    public var confirmSavable: Observable<Bool> {
        return self.subjects.memo
            .map { $0?.content?.isNotEmpty == true }
            .distinctUntilChanged()
    }
}

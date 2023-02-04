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

public protocol LinkMemoViewModel: AnyObject, Sendable {

    // interactor
    func updateContent(_ text: String)
    func deleteMemo()
    func confirmSave()
    func close()
    
    // presenter
    var initialText: String? { get }
    var confirmSavable: Observable<Bool> { get }
}


// MARK: - LinkMemoViewModelImple

public final class LinkMemoViewModelImple: LinkMemoViewModel, @unchecked Sendable {
    
    private let memo: ReadLinkMemo
    private let memoUsecase: ReadLinkMemoUsecase
    private let router: LinkMemoRouting
    private weak var listener: LinkMemoSceneListenable?
    
    public init(memo: ReadLinkMemo,
                memoUsecase: ReadLinkMemoUsecase,
                router: LinkMemoRouting,
                listener: LinkMemoSceneListenable?) {
        
        self.memo = memo
        self.memoUsecase = memoUsecase
        self.router = router
        self.listener = listener
        
        self.subjects.inputText.accept(memo.content)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let inputText = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - LinkMemoViewModelImple Interactor

extension LinkMemoViewModelImple {
    
    public func updateContent(_ text: String) {
        self.subjects.inputText.accept(text)
    }
    
    public func deleteMemo() {
        
        let itemID = self.memo.linkItemID
        let deleted: () -> Void = { [weak self] in
            self?.router.closeScene(animated: true) { [weak self] in
                self?.listener?.linkMemo(didRemoved: itemID)
            }
        }

        self.memoUsecase
            .deleteMemo(for: itemID)
            .subscribe(onSuccess: deleted, onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    public func confirmSave() {
        
        let newMemo = self.memo |> \.content .~ self.subjects.inputText.value
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
    
    private func handleError() -> (Error) -> Void {
        return { [weak self] error in
            self?.router.alertError(error)
        }
    }
    
    public func close() {
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - LinkMemoViewModelImple Presenter

extension LinkMemoViewModelImple {
    
    public var initialText: String? { self.memo.content }
    
    public var confirmSavable: Observable<Bool> {
        return self.subjects.inputText
            .map { $0?.isNotEmpty == true }
            .distinctUntilChanged()
    }
}

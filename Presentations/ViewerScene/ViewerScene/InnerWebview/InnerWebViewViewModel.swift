//
//  InnerWebViewViewModel.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - InnerWebViewViewModel

public protocol InnerWebViewViewModel: AnyObject {

    // interactor
    func prepareLinkData()
    func openPageInSafari()
    func editReadLink()
    func editMemo()
    func toggleMarkAsRed()
    
    // presenter
    var loadURL: String { get }
    var urlPageTitle: Observable<String> { get }
    var isRed: Observable<Bool> { get }
    var hasMemo: Observable<Bool> { get }
}


// MARK: - InnerWebViewViewModelImple

public final class InnerWebViewViewModelImple: InnerWebViewViewModel {
    
    private let link: ReadLink
    private let readItemUsecase: ReadItemUsecase
    private let memoUsecase: ReadLinkMemoUsecase
    private let router: InnerWebViewRouting
    
    public init(link: ReadLink,
                readItemUsecase: ReadItemUsecase,
                memoUsecase: ReadLinkMemoUsecase,
                router: InnerWebViewRouting) {
        
        self.link = link
        self.readItemUsecase = readItemUsecase
        self.memoUsecase = memoUsecase
        self.router = router
        
        self.bindLinkItem(startWith: link)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let item = BehaviorRelay<ReadLink?>(value: nil)
        let isToggling = BehaviorRelay<Bool>(value: false)
        let memo = BehaviorRelay<ReadLinkMemo?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindLinkItem(startWith: ReadLink?) {
        
        self.subjects.item.accept(startWith)
    }
}


// MARK: - InnerWebViewViewModelImple Interactor

extension InnerWebViewViewModelImple {
    
    public func prepareLinkData() {
        guard let item = self.subjects.item.value else { return }
        self.memoUsecase.loadMemo(for: item.uid)
            .subscribe(onNext: { [weak self] memo in
                self?.subjects.memo.accept(memo)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func toggleMarkAsRed() {
        guard let link = self.subjects.item.value,
              self.subjects.isToggling.value == false else { return }
        
        let isToRed = link.isRed.invert()
        let params = ReadItemUpdateParams(item: link)
            |> \.updatePropertyParams .~ [.isRed(isToRed)]
            
        let updated: () -> Void = { [weak self] in
            self?.subjects.isToggling.accept(false)
            let newItem = link |> \.isRed .~ isToRed
            self?.subjects.item.accept(newItem)
        }
        let updateFail: (Error) -> Void = { [weak self] error in
            self?.subjects.isToggling.accept(false)
            self?.router.alertError(error)
        }
        self.subjects.isToggling.accept(true)
        self.readItemUsecase.updateItem(params)
            .subscribe(onSuccess: updated, onError: updateFail)
            .disposed(by: self.disposeBag)
    }
    
    public func openPageInSafari() {
        self.router.openSafariBrowser(self.link.link)
    }
    
    public func editReadLink() {
        self.router.editReadLink(self.link)
    }
}


// MARK: - InnerWebViewViewModelImple Interactor + memo

extension InnerWebViewViewModelImple {
    
    public func editMemo() {
        guard let item = self.subjects.item.value else { return }
        let memo = self.subjects.memo.value ?? ReadLinkMemo(itemID: item.uid)
        self.router.editMemo(memo)
    }
    
    public func linkMemo(didUpdated newVlaue: ReadLinkMemo) {
        guard let item = self.subjects.item.value, item.uid == newVlaue.linkItemID else { return }
        self.subjects.memo.accept(newVlaue)
    }
    
    public func linkMemo(didRemoved linkItemID: String) {
        guard let item = self.subjects.item.value, item.uid == linkItemID else { return }
        self.subjects.memo.accept(nil)
    }
}


// MARK: - InnerWebViewViewModelImple Presenter

extension InnerWebViewViewModelImple {
    
    public var loadURL: String {
        return self.link.link
    }
    
    public var urlPageTitle: Observable<String> {
        
        typealias AddressAndTitle = (address: String, title: String?)
        let customNameInLinkItem = self.subjects.item.compactMap { $0 }
        let orUsePreviewTitle: (ReadLink) -> Observable<AddressAndTitle> = { [weak self] item in
            guard let self = self else { return .empty() }
            return item.customName?.emptyAsNil() != nil
                ? .just((item.link, item.customName))
                : self.readItemUsecase.previewTitle(for: item.link).map { (item.link, $0) }
                
        }
        let elseUseAddress: (AddressAndTitle) -> String = { $0.title?.emptyAsNil() ?? $0.address }
        
        return customNameInLinkItem
            .flatMapLatest(orUsePreviewTitle)
            .map(elseUseAddress)
            .distinctUntilChanged()
    }
    
    public var isRed: Observable<Bool> {
        return self.subjects.item
            .map { $0?.isRed ?? false }
            .distinctUntilChanged()
    }
    
    public var hasMemo: Observable<Bool> {
        return self.subjects.memo
            .map { $0 != nil }
            .distinctUntilChanged()
    }
}


private extension ReadItemUsecase {
    
    func previewTitle(for address: String) -> Observable<String?> {
        return self.loadLinkPreview(address)
            .map { $0.title }
    }
}

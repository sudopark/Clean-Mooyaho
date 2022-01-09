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

public enum LinkItemSource {
    case item(ReadLink)
    case itemID(String)
    
    var item: ReadLink? {
        guard case let .item(link) = self else { return nil }
        return link
    }
    
    var itemID: String {
        switch self {
        case let .item(link): return link.uid
        case let .itemID(id): return id
        }
    }
}

public protocol InnerWebViewViewModel: AnyObject {

    // interactor
    func prepareLinkData()
    func openPageInSafari()
    func editReadLink()
    func editMemo()
    func toggleMarkAsRed()
    func jumpToCollection()
    
    // presenter
    var isEditable: Bool { get }
    var isJumpable: Bool { get }
    var startLoadWebPage: Observable<String> { get }
    var urlPageTitle: Observable<String> { get }
    var isRed: Observable<Bool> { get }
    var hasMemo: Observable<Bool> { get }
}


// MARK: - InnerWebViewViewModelImple

public final class InnerWebViewViewModelImple: InnerWebViewViewModel {
    
    private let itemSource: LinkItemSource
    public let isEditable: Bool
    public let isJumpable: Bool
    private let readItemUsecase: ReadItemUsecase
    private let memoUsecase: ReadLinkMemoUsecase
    private let router: InnerWebViewRouting
    private weak var listener: InnerWebViewSceneListenable?
    
    public init(itemSource: LinkItemSource,
                isEditable: Bool = true,
                isJumpable: Bool = false,
                readItemUsecase: ReadItemUsecase,
                memoUsecase: ReadLinkMemoUsecase,
                router: InnerWebViewRouting,
                listener: InnerWebViewSceneListenable?) {
        
        self.itemSource = itemSource
        self.isEditable = isEditable
        self.isJumpable = isJumpable
        self.readItemUsecase = readItemUsecase
        self.memoUsecase = memoUsecase
        self.router = router
        self.listener = listener
        
        self.bindLinkItem()
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
    
    private func bindLinkItem() {
        let itemID = self.itemSource.itemID
        let prepareItem = self.itemSource.item.map { Observable.just($0) }
            ?? self.readItemUsecase.loadReadLink(itemID)
        
        let updateItem: (ReadLink) -> Void = { [weak self] item in
            self?.subjects.item.accept(item)
            self?.readItemUsecase.updateLinkIsReading(item)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        prepareItem
            .subscribe(onNext: updateItem, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - InnerWebViewViewModelImple Interactor

extension InnerWebViewViewModelImple {
    
    public func prepareLinkData() {
        guard self.isEditable else { return }
        let itemID = self.itemSource.itemID
        
        self.memoUsecase.loadMemo(for: itemID)
            .subscribe(onNext: { [weak self] memo in
                self?.subjects.memo.accept(memo)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func toggleMarkAsRed() {
        guard self.isEditable == true,
              let link = self.subjects.item.value,
              self.subjects.isToggling.value == false else { return }
        
        let isToRed = link.isRed.invert()
            
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
        self.readItemUsecase.updateLinkItemMark(link, asRead: isToRed)
            .subscribe(onSuccess: updated, onError: updateFail)
            .disposed(by: self.disposeBag)
    }
    
    public func openPageInSafari() {
        guard let item = self.subjects.item.value else { return }
        self.router.openSafariBrowser(item.link)
    }
    
    public func editReadLink() {
        guard self.isEditable, let item = self.subjects.item.value else { return }
        self.router.editReadLink(item)
    }
    
    public func jumpToCollection() {
        guard let item = self.subjects.item.value else { return }
        self.listener?.innerWebView(reqeustJumpTo: item.parentID)
    }
}


// MARK: - InnerWebViewViewModelImple Interactor + memo

extension InnerWebViewViewModelImple {
    
    public func editMemo() {
        guard self.isEditable,
                let item = self.subjects.item.value else { return }
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
    
    public var startLoadWebPage: Observable<String> {
        return self.subjects.item
            .compactMap { $0?.link }
            .take(1)
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

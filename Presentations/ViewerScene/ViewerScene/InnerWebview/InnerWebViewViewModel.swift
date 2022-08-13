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
import RxSwiftDoNotation
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

public struct WebPageLoadParams {
    
    public struct LastReadPositionInfo {
        public let position: Double
        public let savedAt: String
        
        public init(_ readPosition: ReadPosition) {
            self.position = readPosition.position
            let timeText = readPosition.saved.dateText(formText: "MMM d, H:mm")
            self.savedAt = "reading-option-last-saved-time".localized(with: timeText)
        }
    }
    
    public let urlPath: String
    public var lastReadPosition: LastReadPositionInfo?
}

public protocol InnerWebViewViewModel: AnyObject, Sendable {

    // interactor
    func prepareLinkData()
    func openPageInSafari()
    func managePageDetail(withCopyURL: Bool)
    func editMemo()
    func toggleMarkAsRed()
    func jumpToCollection()
    func pageLoaded(for url: String)
    func saveLastReadPositionIfNeed(_ position: Double)
    
    // presenter
    var isEditable: Bool { get }
    var isJumpable: Bool { get }
    var startLoadWebPage: Observable<WebPageLoadParams> { get }
    var urlPageTitle: Observable<String> { get }
    var isRed: Observable<Bool> { get }
    var hasMemo: Observable<Bool> { get }
}


// MARK: - InnerWebViewViewModelImple

public final class InnerWebViewViewModelImple: InnerWebViewViewModel, @unchecked Sendable {
    
    private let itemSource: LinkItemSource
    public let isEditable: Bool
    public let isJumpable: Bool
    private let readItemUsecase: ReadItemUsecase
    private let readingOptionUsecase: ReadingOptionUsecase
    private let memoUsecase: ReadLinkMemoUsecase
    private let router: InnerWebViewRouting
    private let clipboardService: ClipboardServie
    private weak var listener: InnerWebViewSceneListenable?
    
    public init(itemSource: LinkItemSource,
                isEditable: Bool = true,
                isJumpable: Bool = false,
                readItemUsecase: ReadItemUsecase,
                readingOptionUsecase: ReadingOptionUsecase,
                memoUsecase: ReadLinkMemoUsecase,
                router: InnerWebViewRouting,
                clipboardService: ClipboardServie,
                listener: InnerWebViewSceneListenable?) {
        
        self.itemSource = itemSource
        self.isEditable = isEditable
        self.isJumpable = isJumpable
        self.readItemUsecase = readItemUsecase
        self.readingOptionUsecase = readingOptionUsecase
        self.memoUsecase = memoUsecase
        self.router = router
        self.clipboardService = clipboardService
        self.listener = listener
        
        self.bindLinkItem()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate typealias ItemAndLastReadInfo = (ReadLink, WebPageLoadParams.LastReadPositionInfo?)
    
    fileprivate final class Subjects: Sendable {
        let itemAndLastReadInfo = BehaviorRelay<ItemAndLastReadInfo?>(value: nil)
        let currentPageURL = BehaviorRelay<String?>(value: nil)
        let isToggling = BehaviorRelay<Bool>(value: false)
        let memo = BehaviorRelay<ReadLinkMemo?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindLinkItem() {
        let itemID = self.itemSource.itemID
        let prepareItem = self.itemSource.item.map { Observable.just($0) }
            ?? self.readItemUsecase.loadReadLink(itemID)
        
        let thenLoadLastReadInfo: @Sendable (ReadLink) async throws -> ItemAndLastReadInfo? = { [weak self] item in
            let lastReadPosition = try await self?.readingOptionUsecase
                .lastReadPosition(for: item.uid).value ?? nil
            return lastReadPosition
                .map { WebPageLoadParams.LastReadPositionInfo($0) }
                .map { (item, $0) } ?? (item, nil)
        }
        
        let updateItem: (ItemAndLastReadInfo) -> Void = { [weak self] info in
            self?.subjects.itemAndLastReadInfo.accept(info)
            self?.readItemUsecase.updateLinkIsReading(info.0)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        prepareItem
            .flatMap(do: thenLoadLastReadInfo)
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
              let info = self.subjects.itemAndLastReadInfo.value,
              self.subjects.isToggling.value == false else { return }
        let link = info.0
        
        let isToRed = link.isRed.invert()
            
        let updated: () -> Void = { [weak self] in
            self?.subjects.isToggling.accept(false)
            let newItem = link |> \.isRed .~ isToRed
            self?.subjects.itemAndLastReadInfo.accept((newItem, info.1))
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
        guard let item = self.subjects.itemAndLastReadInfo.value?.0 else { return }
        self.router.openSafariBrowser(item.link)
    }
    
    public func managePageDetail(withCopyURL: Bool) {
        if withCopyURL {
            self.copyCurrentItemURL()
        }
        self.editReadLink()
    }
    
    private func editReadLink() {
        guard self.isEditable,
              let item = self.subjects.itemAndLastReadInfo.value?.0
        else { return }
        self.router.editReadLink(item)
    }
    
    private func copyCurrentItemURL() {
        guard let url = self.subjects.itemAndLastReadInfo.value?.0.link else { return }
        self.clipboardService.copy(url)
        self.router.showToast("Item address has been copied.".localized)
    }
    
    public func jumpToCollection() {
        guard let item = self.subjects.itemAndLastReadInfo.value?.0 else { return }
        self.router.closeScene(animated: false) { [weak self] in
            self?.listener?.innerWebView(reqeustJumpTo: item.parentID)
        }
    }
    
    public func pageLoaded(for url: String) {
        self.subjects.currentPageURL.accept(url)
    }
    
    public func saveLastReadPositionIfNeed(_ position: Double) {
        guard let item = self.subjects.itemAndLastReadInfo.value?.0,
              let encodedURL = item.link.asURL()?.absoluteString,
              encodedURL == self.subjects.currentPageURL.value
        else { return }
        
        self.readingOptionUsecase
            .updateLastReadPositionIsPossible(for: item.uid, position: position)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}


// MARK: - InnerWebViewViewModelImple Interactor + memo

extension InnerWebViewViewModelImple {
    
    public func editMemo() {
        guard self.isEditable,
                let item = self.subjects.itemAndLastReadInfo.value?.0
        else { return }
        let memo = self.subjects.memo.value ?? ReadLinkMemo(itemID: item.uid)
        self.router.editMemo(memo)
    }
    
    public func linkMemo(didUpdated newVlaue: ReadLinkMemo) {
        guard let item = self.subjects.itemAndLastReadInfo.value?.0,
              item.uid == newVlaue.linkItemID
        else { return }
        self.subjects.memo.accept(newVlaue)
    }
    
    public func linkMemo(didRemoved linkItemID: String) {
        guard let item = self.subjects.itemAndLastReadInfo.value?.0,
              item.uid == linkItemID
        else { return }
        self.subjects.memo.accept(nil)
    }
}


// MARK: - InnerWebViewViewModelImple Presenter

extension InnerWebViewViewModelImple {
    
    public var startLoadWebPage: Observable<WebPageLoadParams> {
        return self.subjects.itemAndLastReadInfo
            .compactMap { $0 }
            .map { WebPageLoadParams(urlPath: $0.0.link, lastReadPosition: $0.1) }
            .take(1)
    }
    
    public var urlPageTitle: Observable<String> {
        
        typealias AddressAndTitle = (address: String, title: String?)
        let customNameInLinkItem = self.subjects.itemAndLastReadInfo.compactMap { $0?.0 }
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
        return self.subjects.itemAndLastReadInfo
            .map { $0?.0 }
            .map { $0?.isRed ?? false }
            .distinctUntilChanged()
    }
    
    public var hasMemo: Observable<Bool> {
        return self.subjects.memo
            .map { $0 != nil }
            .distinctUntilChanged()
    }
    
    public var lastReadPosition: Observable<Float?> {
        return .empty()
    }
}


private extension ReadItemUsecase {
    
    func previewTitle(for address: String) -> Observable<String?> {
        return self.loadLinkPreview(address)
            .map { $0.title }
    }
}

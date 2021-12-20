//
//  ReadItemUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/12.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


public enum ReadItemUpdateEvent: SharedEvent {
    case updated(_ item: ReadItem)
    case removed(itemID: String, parent: String?)
}

// MARK: - ReadItemUsecase

public protocol ReadItemUsecase: ReadItemLoadUsecase, ReadItemUpdateUsecase, ReadItemOptionsUsecase, FavoriteReadItemUsecas {
    
    var readItemUpdated: Observable<ReadItemUpdateEvent> { get }
}


// MARK: - ReadItemUsecaseImple

public final class ReadItemUsecaseImple: ReadItemUsecase {
    
    let itemsRespoitory: ReadItemRepository
    private let previewRepository: LinkPreviewRepository
    private let optionsRespository: ReadItemOptionsRepository
    private let authInfoProvider: AuthInfoProvider
    private let sharedStoreService: SharedDataStoreService
    private let clipBoardService: ClipboardServie
    private let sharedEventService: SharedEventService
    private let remindPreviewLoadTimeout: TimeInterval
    private let remindMessagingService: ReadRemindMessagingService
    private let shareURLScheme: String
    
    private let disposeBag = DisposeBag()
    
    public init(itemsRespoitory: ReadItemRepository,
                previewRepository: LinkPreviewRepository,
                optionsRespository: ReadItemOptionsRepository,
                authInfoProvider: AuthInfoProvider,
                sharedStoreService: SharedDataStoreService,
                clipBoardService: ClipboardServie,
                sharedEventService: SharedEventService,
                remindPreviewLoadTimeout: TimeInterval = 3.0,
                remindMessagingService: ReadRemindMessagingService,
                shareURLScheme: String) {
        
        self.itemsRespoitory = itemsRespoitory
        self.previewRepository = previewRepository
        self.optionsRespository = optionsRespository
        self.authInfoProvider = authInfoProvider
        self.sharedStoreService = sharedStoreService
        self.clipBoardService = clipBoardService
        self.sharedEventService = sharedEventService
        self.remindPreviewLoadTimeout = remindPreviewLoadTimeout
        self.remindMessagingService = remindMessagingService
        self.shareURLScheme = shareURLScheme
    }
}


extension ReadItemUsecaseImple {
    
    public func loadMyItems() -> Observable<[ReadItem]> {
        let memberID = self.authInfoProvider.signedInMemberID()
        return self.itemsRespoitory
            .requestLoadMyItems(for: memberID)
            .map {$0.removeAlreadyPassedRemind() }
    }
    
    public func loadCollectionInfo(_ collectionID: String) -> Observable<ReadCollection> {
        return self.itemsRespoitory
            .requestLoadCollection(collectionID)
            .map { $0.removeAlreadyPassedRemind() }
    }
    
    public func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        return self.itemsRespoitory
            .requestLoadCollectionItems(collectionID: collectionID)
            .map { $0.removeAlreadyPassedRemind() }
    }
    
    public func loadReadLink(_ linkID: String) -> Observable<ReadLink> {
        return self.itemsRespoitory
            .requestLoadReadLinkItem(linkID)
            .map { $0.removeAlreadyPassedRemind() }
    }
    
    public func loadLinkPreview(_ url: String) -> Observable<LinkPreview> {
        
        let key = SharedDataKeys.readLinkPreviewMap
        
        let isPreviewExistInMemory = self.sharedStoreService
            .isExists([String: LinkPreview].self, key: key) { $0?[url] != nil }
        
        let preparePreviewIfNeed: () -> Void = { [weak self] in
            guard isPreviewExistInMemory == false else { return }
            self?.prepreLinkPreview(url)
        }
        
        return self.sharedStoreService
            .observeWithCache([String: LinkPreview].self, key: key.rawValue)
            .compactMap { $0?[url] }
            .do(onSubscribed: preparePreviewIfNeed)
    }
    
    private func prepreLinkPreview(_ url: String) {
        
        let updateStore: (LinkPreview) -> Void = { [weak self] preview in
            guard let self = self else { return }
            let datKey = SharedDataKeys.readLinkPreviewMap
            self.sharedStoreService.update([String: LinkPreview].self, key: datKey.rawValue) {
                ($0 ?? [:]) |> key(url) .~ preview
            }
        }
        
        self.previewRepository.loadLinkPreview(url)
            .subscribe(onSuccess: updateStore)
            .disposed(by: self.disposeBag)
    }
    
    public func suggestNextReadItem(size: Int) -> Maybe<[ReadItem]> {
        let currentMemberID = self.authInfoProvider.signedInMemberID()
        return self.itemsRespoitory.requestSuggestNextReadItems(for: currentMemberID, size: size)
    }
    
    public func continueReadingLinks() -> Observable<[ReadLink]> {
        let datKey = SharedDataKeys.currentReadingItems.rawValue
        
        let filterAlreadyRed: ([ReadLink]) -> [ReadLink] = { items in
            return items.filter { $0.isRed == false }
        }
        return self.sharedStoreService
            .observeWithCache([ReadLink].self, key: datKey)
            .map { $0 ?? [] }
            .map(filterAlreadyRed)
            .do(onSubscribed: { [weak self] in
                self?.fetchCurrentReadingItems()
            })
    }
    
    private func fetchCurrentReadingItems() {
        let datKey = SharedDataKeys.currentReadingItems.rawValue
        let updateStore: ([ReadLink]) -> Void = { [weak self] links in
            self?.sharedStoreService.update([ReadLink].self, key: datKey, value: links)
        }
        self.itemsRespoitory.fetchUserReadingLinks()
            .subscribe(onSuccess: updateStore)
            .disposed(by: self.disposeBag)
    }
    
    public func loadReadItems(for itemIDs: [String]) -> Maybe<[ReadItem]> {
        return self.itemsRespoitory.requestLoadItems(ids: itemIDs)
    }
}


// MARK: - FavoriteReadItemUsecas

extension ReadItemUsecaseImple: FavoriteReadItemUsecas {
    
    public func refreshSharedFavoriteIDs() {
        self.refreshFavoriteIDs()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func refreshFavoriteIDs() -> Observable<[String]> {
        let updateStore: ([String]) -> Void = { [weak self] ids in
            let datKey = SharedDataKeys.favoriteItemIDs.rawValue
            self?.sharedStoreService.update([String].self, key: datKey, value: ids)
        }
        return self.itemsRespoitory.requestRefreshFavoriteItemIDs()
            .do(onNext: updateStore)
    }
    
    public func toggleFavorite(itemID: String, toOn: Bool) -> Maybe<Void> {
        
        let updateStore: () -> Void = { [weak self] in
            let datKey = SharedDataKeys.favoriteItemIDs.rawValue
            self?.sharedStoreService.update([String].self, key: datKey) {
                let filteredIDs = ($0 ?? []).filter { $0 != itemID }
                return toOn ? filteredIDs + [itemID] : filteredIDs
            }
        }
        
        return self.itemsRespoitory.toggleItemIsFavorite(itemID, toOn: toOn)
            .do(onNext: updateStore)
    }
    
    public var sharedFavoriteItemIDs: Observable<[String]> {
        let datKey = SharedDataKeys.favoriteItemIDs.rawValue
        return self.sharedStoreService
            .observeWithCache([String].self, key: datKey)
            .map { $0 ?? [] }
    }
}


// MARK: - update item

extension ReadItemUsecaseImple {
    
    public func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        let memberID = self.authInfoProvider.signedInMemberID()
        let newCollection = newCollection |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateCollection(newCollection)
            .do(onNext: self.broadCastItemUpdated(newCollection))
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        let memberID = self.authInfoProvider.signedInMemberID()
        let link = link |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateLink(link)
            .do(onNext: self.broadCastItemUpdated(link))
    }
    
    public func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return self.itemsRespoitory.requestUpdateItem(params)
            .do(onNext: self.broadCastItemUpdated(params.applyChanges()))
    }
    
    public func updateLinkItemMark(_ link: ReadLink, asRead: Bool) -> Maybe<Void> {
        let removeFromContinueReadingListIfNeed: () -> Void = { [weak self] in
            guard asRead else { return }
            self?.removeFromContinueReadingLinks(id: link.uid)
        }
        
        var params = ReadItemUpdateParams(item: link)
        params.updatePropertyParams = [.isRed(asRead)]
        return self.updateItem(params)
            .do(onNext: removeFromContinueReadingListIfNeed)
    }
    
    private func removeFromContinueReadingLinks(id: String) {
        let datKey = SharedDataKeys.currentReadingItems.rawValue
        self.sharedStoreService.update([ReadLink].self, key: datKey) {
            return ($0 ?? []).filter { $0.uid != id }
        }
    }
    
    private func broadCastItemUpdated(_ newItem: ReadItem) -> () -> Void {
        return { [weak self] in
            let event: ReadItemUpdateEvent = .updated(newItem)
            self?.sharedEventService.notify(event: event)
        }
    }
    
    public func removeItem(_ item: ReadItem) -> Maybe<Void> {
        
        let broadCastItemRemoved: () -> Void = { [weak self] in
            let event: ReadItemUpdateEvent = .removed(itemID: item.uid, parent: item.parentID)
            self?.sharedEventService.notify(event: event)
            if item is ReadLink {
                self?.removeFromContinueReadingLinks(id: item.uid)
            }
        }
        return self.itemsRespoitory.requestRemove(item: item)
            .do(onNext: broadCastItemRemoved)
    }
    
    public func updateLinkIsReading(_ link: ReadLink) {
        guard link.isRed == false else { return }
        self.itemsRespoitory.updateLinkItemIsReading(link.uid)
        let datKey = SharedDataKeys.currentReadingItems.rawValue
        self.sharedStoreService.update([ReadLink].self, key: datKey) {
            return ($0 ?? []).filter { $0.uid != link.uid } + [link]
        }
    }
}


// MARK: - ReadItemOptionsUsecase

extension ReadItemUsecaseImple {
    
    private func sharedStream<V>(_ sharedKey: SharedDataKeys,
                                 refreshing: @escaping () -> Maybe<V>) -> Observable<V> {
        
        let refreshIfNeed: () -> Void = { [weak self] in
            let isExist = self?.sharedStoreService.isExists(V.self, key: sharedKey) { $0 != nil }
            guard let self = self, isExist == false else { return }
            
            let updateOnStore: (V) -> Void = { value in
                self.sharedStoreService.update(V.self, key: sharedKey.rawValue, value: value)
            }
            refreshing()
                .subscribe(onSuccess: updateOnStore)
                .disposed(by: self.disposeBag)
        }
        return self.sharedStoreService
            .observeWithCache(V.self, key: sharedKey.rawValue)
            .compactMap { $0 }
            .do(onSubscribe: refreshIfNeed)
    }
    
    public var isShrinkModeOn: Observable<Bool> {
        let refreshing: () -> Maybe<Bool> = { [weak self] in
            return self?.optionsRespository
                .fetchLastestsIsShrinkModeOn().map { $0 ?? false } ?? .empty()
        }
        return self.sharedStream(.readItemShrinkIsOn, refreshing: refreshing)
    }
    
    public func updateLatestIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
        
        let updateOnStore: () -> Void = { [weak self] in
            self?.sharedStoreService.save(Bool.self, key: .readItemShrinkIsOn, newvalue)
        }
        return self.optionsRespository.updateLatestIsShrinkModeOn(newvalue)
            .do(onNext: updateOnStore)
    }
    
    private typealias CustomOrdersMap = [String: [String]]
    private var orderKey: SharedDataKeys { .latestReadItemSortOption }
    private var customOrderKey: SharedDataKeys { .readItemCustomOrderMap }
    
    public var sortOrder: Observable<ReadCollectionItemSortOrder> {
        
        let refresh: () -> Maybe<ReadCollectionItemSortOrder> = { [weak self] in
            return self?.optionsRespository
                .fetchLatestSortOrder().map { $0 ?? .default } ?? .empty()
        }
        return self.sharedStream(self.orderKey, refreshing: refresh)
    }
    
    public func updateLatestSortOption(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        
        let key = self.orderKey
        
        let updateOnStore: () -> Void = { [weak self] in
            self?.sharedStoreService
                .update(ReadCollectionItemSortOrder.self, key: key.rawValue, value: newValue)
        }
        return self.optionsRespository.updateLatestSortOrder(to: newValue)
            .do(onNext: updateOnStore)
    }
    
    public func customOrder(for collectionID: String) -> Observable<[String]> {
        
        let datKey = self.customOrderKey
        
        return self.sharedStoreService
            .observeWithCache([String: [String]].self, key: datKey.rawValue)
            .compactMap { $0?[collectionID] }
            .do(onSubscribed: { [weak self] in
                self?.prepareObservableCustomOrderIfNeed(collectionID)
            })
    }
    
    private func prepareObservableCustomOrderIfNeed(_ collectionID: String) {
        
        let datKey = self.customOrderKey
        
        let preloadedExists = self.sharedStoreService
            .fetch(CustomOrdersMap.self, key: datKey)?[collectionID] != nil
        
        guard preloadedExists == false else { return }
        
        let updateOrderOnStore: ([String]) -> Void = { [weak self] ids in
            guard let self = self else { return }
            self.sharedStoreService.update(CustomOrdersMap.self, key: datKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ ids
            }
        }
        
        self.optionsRespository.requestLoadCustomOrder(for: collectionID)
            .ifEmpty(default: [])
            .subscribe(onNext: updateOrderOnStore)
            .disposed(by: self.disposeBag)
    }
    
    public func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        let updateOnLocal: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.sharedStoreService.update(CustomOrdersMap.self, key: self.customOrderKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ itemIDs
            }
        }
        return self.optionsRespository.requestUpdateCustomSortOrder(for: collectionID, itemIDs: itemIDs)
            .do(onNext: updateOnLocal)
    }
    
    public var readItemUpdated: Observable<ReadItemUpdateEvent> {
        return self.sharedEventService.event
            .compactMap { $0 as? ReadItemUpdateEvent }
    }
}


// MARK; - ReadLinkAddSuggestUsecase

extension ReadItemUsecaseImple: ReadLinkAddSuggestUsecase {
    
    public func loadSuggestAddNewItemByURLExists() -> Maybe<String?> {
        
        guard let copiedURL = self.clipBoardService.getCopedString(),
              copiedURL.isURLAddress else { return .just(nil) }
        
        guard copiedURL.starts(with: self.shareURLScheme) == false
        else {
            return .just(nil)
        }
        
        let isNotSuggestedBefore = self.isSuggestedBefore(copiedURL) == false
        guard isNotSuggestedBefore else { return .just(nil) }
        
        let findItem = self.itemsRespoitory.requestFindLinkItem(using: copiedURL)
        
        let checkIsNotAdded: (ReadLink?) -> String? = { item in
            return item == nil ? copiedURL : nil
        }
        
        let updateSuggested: (String?) -> Void = { [weak self] url in
            guard let self = self, let url = url else { return }
            let datKey = SharedDataKeys.addSuggestedURLSet
            self.sharedStoreService.update(Set<String>.self, key: datKey.rawValue) {
                return ($0 ?? []).union([url])
            }
        }
        
        return findItem
            .map(checkIsNotAdded)
            .do(onNext: updateSuggested)
    }
    
    private func isSuggestedBefore(_ url: String) -> Bool {
        guard let suggestSet = self.sharedStoreService
                .fetch(Set<String>.self, key: .addSuggestedURLSet) else {
            return false
        }
        return suggestSet.contains(url)
    }
}


extension ReadItemUsecaseImple: ReadRemindUsecase {
    
    public func preparePermission() -> Maybe<Bool> {
        return self.remindMessagingService.prepareNotificationPermission()
    }
    
    public func updateRemind(for item: ReadItem, futureTime: TimeStamp?) -> Maybe<Void> {
        
        let makeOrCancelRemind: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return futureTime
                .map { self.scheduleRemindMessage(for: item, at: $0) }
                ?? self.cancelRemindMessage(item)
        }
        
        return self.updateItem(item, remindTime: futureTime)
            .flatMap(makeOrCancelRemind)
    }
    
    public func scheduleRemindMessage(for item: ReadItem, at futureTime: TimeStamp) -> Maybe<Void> {

        let prepareReadRemindMessage = self.prepareReadRemindMessage(for: item, time: futureTime)
        
        let sendPendingMessage: (ReadRemindMessage) -> Maybe<Void> = { [weak self] message in
            return self?.remindMessagingService.sendPendingMessage(message) ?? .empty()
        }
        
        return prepareReadRemindMessage
            .flatMap(sendPendingMessage)
    }
    
    public func cancelRemindMessage(_ item: ReadItem) -> Maybe<Void> {
        return self.remindMessagingService.cancelMessage(for: item.uid)
    }
    
    private func updateItem(_ item: ReadItem, remindTime: TimeStamp?) -> Maybe<Void> {
        let params = ReadItemUpdateParams(item: item)
            |> \.updatePropertyParams .~ [.remindTime(remindTime)]
        return self.updateItem(params)
    }
    
    private func prepareReadRemindMessage(for item: ReadItem,
                                          time: TimeStamp) -> Maybe<ReadRemindMessage> {
        
        let message = ReadRemindMessage(itemID: item.uid, scheduledTime: time)
        switch item {
        case let collection as ReadCollection:
            return message
                |> \.message .~ pure("It's time to start read '%@' read collection".localized(with: collection.name))
                |> Maybe.just
            
        case let link as ReadLink:
            let loadPreviewWithTimeout = self.loadLinkPreview(link.link).take(1)
                .timeout(.milliseconds(Int(self.remindPreviewLoadTimeout * 1000)),
                         scheduler: MainScheduler.instance)
                .asMaybe()
            let decorateMessage: (LinkPreview?) -> ReadRemindMessage = { preview in
                return message
                |> \.message .~ pure(preview?.title ?? "\(ReadRemindMessage.defaultReadLinkMessage)(\(link.link))")
            }
            return loadPreviewWithTimeout
                .mapAsOptional().catchAndReturn(nil)
                .map(decorateMessage)
                
        default: return .just(message)
        }
    }
    
    public func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void> {
        return self.remindMessagingService.broadcastRemind(readReminder)
    }
}


private extension ReadItem {
    
    func removeAlreadyPassedRemind() -> Self {
        let isPassed = self.remindTime.map { $0 <= .now() } ?? false
        return isPassed ? (self |> \.remindTime .~ nil) : self
    }
}

private extension Array where Element == ReadItem {
    
    func removeAlreadyPassedRemind() -> [Element] {
        return self.map { $0.removeAlreadyPassedRemind() }
    }
}

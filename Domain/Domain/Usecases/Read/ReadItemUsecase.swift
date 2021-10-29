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


public enum ReadItemUpdateEvent {
    case updated(_ item: ReadItem)
    case removed(itemID: String, parent: String?)
}

// MARK: - ReadItemUsecase

public protocol ReadItemUsecase: ReadItemLoadUsecase, ReadItemUpdateUsecase, ReadItemOptionsUsecase {
    
    var readItemUpdated: Observable<ReadItemUpdateEvent> { get }
}


// MARK: - ReadItemUsecaseImple

public final class ReadItemUsecaseImple: ReadItemUsecase {
    
    private let itemsRespoitory: ReadItemRepository
    private let previewRepository: LinkPreviewRepository
    private let optionsRespository: ReadItemOptionsRepository
    private let authInfoProvider: AuthInfoProvider
    private let sharedStoreService: SharedDataStoreService
    
    private let disposeBag = DisposeBag()
    
    public init(itemsRespoitory: ReadItemRepository,
                previewRepository: LinkPreviewRepository,
                optionsRespository: ReadItemOptionsRepository,
                authInfoProvider: AuthInfoProvider,
                sharedStoreService: SharedDataStoreService) {
        self.itemsRespoitory = itemsRespoitory
        self.previewRepository = previewRepository
        self.optionsRespository = optionsRespository
        self.authInfoProvider = authInfoProvider
        self.sharedStoreService = sharedStoreService
    }
    
    private static let readItemUpdated = PublishSubject<ReadItemUpdateEvent>()
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
            .map {$0.removeAlreadyPassedRemind() }
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
}


extension ReadItemUsecaseImple {
    
    public func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        let memberID = self.authInfoProvider.signedInMemberID()
        let newCollection = newCollection |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateCollection(newCollection)
            .do(onNext: { [weak self] in
                self?.broadCastItemUpdated(newCollection)
            })
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        let memberID = self.authInfoProvider.signedInMemberID()
        let link = link |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateLink(link)
            .do(onNext: { [weak self] in
                self?.broadCastItemUpdated(link)
            })
    }
    
    public func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return self.itemsRespoitory.requestUpdateItem(params)
            .do(onNext: { [weak self] in
                let newItem = params.applyChanges()
                self?.broadCastItemUpdated(newItem)
            })
    }
    
    private func broadCastItemUpdated(_ newItem: ReadItem) {
        Self.readItemUpdated.onNext(.updated(newItem))
    }
}


// MARKK: - ReadItemOptionsUsecase

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
        return Self.readItemUpdated.asObservable()
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

public extension ReadItemUpdateParams {
    
    func applyChanges() -> ReadItem {
        return self.updatePropertyParams.reduce(self.item) { acc, property in
            return property.applyChange(to: acc)
        }
    }
}

private extension ReadItemUpdateParams.ProperyUpdateParams {
    
    func applyChange(to item: ReadItem) -> ReadItem {
        switch self {
        case let .remindTime(time):
            return item |> \.remindTime .~ time
            
        case let .isRed(flag):
            return (item as? ReadLink).map { $0 |> \.isRed .~ flag } ?? item
            
        case let .parentID(id):
            return item |> \.parentID .~ id
        }
    }
}

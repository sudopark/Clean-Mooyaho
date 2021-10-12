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


// MARK: - ReadItemUsecase

public protocol ReadItemUsecase: ReadItemLoadUsecase, ReadItemUpdateUsecase, ReadItemOptionsUsecase { }


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
}


extension ReadItemUsecaseImple {
    
    public func loadMyItems() -> Observable<[ReadItem]> {
        let memberID = self.authInfoProvider.signedInMemberID()
        return self.itemsRespoitory.requestLoadMyItems(for: memberID)
    }
    
    public func loadCollectionInfo(_ collectionID: String) -> Observable<ReadCollection> {
        return self.itemsRespoitory.requestLoadCollection(collectionID)
    }
    
    public func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        return self.itemsRespoitory.requestLoadCollectionItems(collectionID: collectionID)
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
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        let memberID = self.authInfoProvider.signedInMemberID()
        let link = link |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateLink(link)
    }
}


// MARKK: - ReadItemOptionsUsecase

extension ReadItemUsecaseImple {
    
    public func loadLatestShrinkModeIsOnOption() -> Maybe<Bool> {
        let preloadedValue = self.sharedStoreService.fetch(Bool.self, key: .readItemShrinkIsOn)
        
        let updateOnStore: (Bool) -> Void = { [weak self] isOn in
            self?.sharedStoreService.save(Bool.self, key: .readItemShrinkIsOn, isOn)
        }
        let loadOnLocal = self.optionsRespository
            .fetchLastestsIsShrinkModeOn()
            .map { $0 ?? false }
            .do(onNext: updateOnStore)
        
        return preloadedValue.map{ .just($0 )} ?? loadOnLocal
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
    
    public func loadLatestSortOption() -> Maybe<ReadCollectionItemSortOrder> {

        let key = self.orderKey
        
        let updateLastestValueOnStore: (ReadCollectionItemSortOrder) -> Void = { [weak self] newValue in
            self?.sharedStoreService
                .update(ReadCollectionItemSortOrder.self, key: key.rawValue, value: newValue)
        }
        let refreshedSortOption = self.optionsRespository.fetchLatestSortOrder()
            .map { $0 ?? .default }
            .do(onNext: updateLastestValueOnStore)
        
        let preloaded = self.sharedStoreService.fetch(ReadCollectionItemSortOrder.self, key: key)
                
        return preloaded.map { .just($0) } ?? refreshedSortOption
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
        
        let updateOrderOnStore: ([String]) -> Void = { [weak self] ids in
            guard let self = self else { return }
            self.sharedStoreService.update(CustomOrdersMap.self, key: datKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ ids
            }
        }
        let refreshedOrders = self.optionsRespository.requestLoadCustomOrder(for: collectionID)
            .do(onNext: updateOrderOnStore)
            .ifEmpty(default: [])
                
        let preloaded = self.sharedStoreService
            .fetch(CustomOrdersMap.self, key: datKey)?[collectionID]
                
        return preloaded.map { .just ($0) } ?? refreshedOrders
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
}

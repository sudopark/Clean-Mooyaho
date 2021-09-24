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
    private let optionsRespository: ReadItemOptionsRepository
    private let authInfoProvider: AuthInfoProvider
    private let sharedStoreService: SharedDataStoreService
    
    public init(itemsRespoitory: ReadItemRepository,
                optionsRespository: ReadItemOptionsRepository,
                authInfoProvider: AuthInfoProvider,
                sharedStoreService: SharedDataStoreService) {
        self.itemsRespoitory = itemsRespoitory
        self.optionsRespository = optionsRespository
        self.authInfoProvider = authInfoProvider
        self.sharedStoreService = sharedStoreService
    }
}


extension ReadItemUsecaseImple {
    
    public func loadMyItems() -> Observable<[ReadItem]> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.itemsRespoitory.fetchMyItems().asObservable()
        }
        return self.itemsRespoitory.requestLoadMyItems(for: memberID)
    }
    
    public func loadCollectionInfo(_ collectionID: String) -> Observable<ReadCollection> {
        // TODO: should imple
        return .empty()
    }
    
    public func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        guard self.authInfoProvider.isSignedIn() else {
            return self.itemsRespoitory
                .fetchCollectionItems(collectionID: collectionID).asObservable()
        }
        return self.itemsRespoitory.requestLoadCollectionItems(collectionID: collectionID)
    }
}


extension ReadItemUsecaseImple {
    
    public func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.itemsRespoitory.updateCollection(newCollection)
        }
        let newCollection = newCollection |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateCollection(newCollection)
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.itemsRespoitory.updateLink(link)
        }
        let link = link |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateLink(link)
    }
}


// MARKK: - ReadItemOptionsUsecase

extension ReadItemUsecaseImple {
    
    public func loadShrinkModeIsOnOption() -> Maybe<Bool> {
        let preloadedValue = self.sharedStoreService.fetch(Bool.self, key: .readItemShrinkIsOn)
        
        let updateOnStore: (Bool) -> Void = { [weak self] isOn in
            self?.sharedStoreService.save(Bool.self, key: .readItemShrinkIsOn, isOn)
        }
        let loadOnLocal = self.optionsRespository
            .fetchLastestsIsShrinkModeOn()
            .do(onNext: updateOnStore)
        
        return preloadedValue.map{ .just($0 )} ?? loadOnLocal
    }
    
    public func updateIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
        
        let updateOnStore: () -> Void = { [weak self] in
            self?.sharedStoreService.save(Bool.self, key: .readItemShrinkIsOn, newvalue)
        }
        return self.optionsRespository.updateIsShrinkModeOn(newvalue)
            .do(onNext: updateOnStore)
    }
    
    private typealias OrderMap = [String: ReadCollectionItemSortOrder]
    private typealias CustomOrdersMap = [String: [String]]
    private var orderKey: SharedDataKeys { .readItemSortOptionMap }
    private var customOrderKey: SharedDataKeys { .readItemCustomOrderMap }
    
    public func loadLatestSortOption(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder> {
        
        let loadSortOrderForGivenCollection = self.loadSortOrder(for: collectionID)
        
        let selectLatestUsedSortorderOrDefaultIfNeed: (ReadCollectionItemSortOrder?) -> ReadCollectionItemSortOrder
        selectLatestUsedSortorderOrDefaultIfNeed = { [weak self] order in
            return order
                ?? self?.sharedStoreService.fetch(ReadCollectionItemSortOrder.self, key: .latestReadItemSortOption)
                ?? .default
        }
        let updateLastestValueOnStore: (ReadCollectionItemSortOrder) -> Void = { [weak self] newValue in
            let key = SharedDataKeys.latestReadItemSortOption.rawValue
            self?.sharedStoreService.update(ReadCollectionItemSortOrder.self, key: key, value: newValue)
        }
        
        return loadSortOrderForGivenCollection
            .map(selectLatestUsedSortorderOrDefaultIfNeed)
            .do(onNext: updateLastestValueOnStore)
    }
    
    private func loadSortOrder(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder?> {
        
        let preloadedValue = self.sharedStoreService.fetch(OrderMap.self, key: self.orderKey)?[collectionID]
        
        let updateOrderMapOnStoreOrNot: (ReadCollectionItemSortOrder?) -> Void = { [weak self] order in
            guard let self = self, let order = order else { return }
            self.sharedStoreService.update(OrderMap.self, key: self.orderKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ order
            }
        }
        let loadonLocal = self.optionsRespository.fetchSortOrder(for: collectionID)
            .do(onNext: updateOrderMapOnStoreOrNot)
        
        return preloadedValue.map { .just($0) } ?? loadonLocal
    }
    
    public func updateSortOption(for collectionID: String, to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        let updateOnStore: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.sharedStoreService.update(OrderMap.self, key: self.orderKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ newValue
            }
            self.sharedStoreService
                .update(ReadCollectionItemSortOrder.self, key: SharedDataKeys.latestReadItemSortOption.rawValue, value: newValue)
        }
        return self.optionsRespository.updateSortOrder(for: collectionID, to: newValue)
            .do(onNext: updateOnStore)
    }
    
    public func loadCustomOrder(for collectionID: String) -> Maybe<[String]> {
        let preloaded = self.sharedStoreService.fetch(CustomOrdersMap.self, key: self.customOrderKey)?[collectionID]
            
        let updateOnLocal: ([String]) -> Void = { [weak self] ids in
            guard let self = self else { return }
            self.sharedStoreService.update(CustomOrdersMap.self, key: self.customOrderKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ ids
            }
        }
        let loadOnLocal = self.optionsRespository.fetchCustomSortOrder(for: collectionID)
            .do(onNext: updateOnLocal)
        
        return preloaded.map{ .just($0) } ?? loadOnLocal
    }
    
    public func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        let updateOnLocal: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.sharedStoreService.update(CustomOrdersMap.self, key: self.customOrderKey.rawValue) {
                return ($0 ?? [:]) |> key(collectionID) .~ itemIDs
            }
        }
        return self.optionsRespository.updateCustomSortOrder(for: collectionID, itemIDs: itemIDs)
            .do(onNext: updateOnLocal)
    }
}

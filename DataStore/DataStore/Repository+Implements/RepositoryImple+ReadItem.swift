//
//  RepositoryImple+ReadItem.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadItemRepositryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var readItemRemote: ReadItemRemote { get }
    var readItemLocal: ReadItemLocalStorage { get }
}

extension ReadItemRepository where Self: ReadItemRepositryDefImpleDependency, Self: ReadLinkMemoRepository {
    
    public func requestLoadMyItems(for memberID: String?) -> Observable<[ReadItem]> {
        
        let itemsOnLocal = self.readItemLocal.fetchMyItems(memberID: memberID)
        guard let memberID = memberID else {
            return itemsOnLocal.catchAndReturn([]).asObservable()
        }
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }

        let itemsOnRemote = self.readItemRemote.requestLoadMyItems(for: memberID)
            .do(onNext: updateLocal)
        
        return itemsOnLocal.catchAndReturn([]).asObservable()
            .concat(itemsOnRemote)
        
    }
    
    public func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]> {
        
        let itemsOnLocal = self.readItemLocal.fetchCollectionItems(collectionID)
        
        let updateLocal: ([ReadItem]) -> Void = { [weak self] items in
            guard let self = self else { return }
            self.readItemLocal.updateReadItems(items).subscribe().disposed(by: self.disposeBag)
        }
        let itemsOnRemote = self.readItemRemote
            .requestLoadCollectionItems(collectionID: collectionID)
            .do(onNext: updateLocal)
            
        return itemsOnLocal.catchAndReturn([]).asObservable()
            .concat(itemsOnRemote)
    }

    public func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void> {

        let updateOnLocal = { [weak self] in self?.readItemLocal.updateReadItems([collection]) ?? .empty() }
        let updateOnRemote = self.readItemRemote.requestUpdateReadCollection(collection)
        return updateOnRemote.switchOr(append: updateOnLocal, witoutError: ())
    }
    
    public func requestUpdateLink(_ link: ReadLink) -> Maybe<Void> {
        let updateOnLocal = { [weak self] in self?.readItemLocal.updateReadItems([link]) ?? .empty() }
        let updateOnRemote = self.readItemRemote.requestUpdateReadLink(link)
        
        let removeFromCurentReading: () -> Void = { [weak self] in
            guard let self = self, link.isRed else { return }
            self.readItemLocal.updateLinkItemIsReading(id: link.uid, isReading: false)
        }
        
        return updateOnRemote.switchOr(append: updateOnLocal, witoutError: ())
            .do(onNext: removeFromCurentReading)
    }
   
    public func requestLoadCollection(_ collectionID: String) -> Observable<ReadCollection> {
        
        let thenUdateLocal: (ReadCollection) -> Void = { [weak self] collection in
            self?.updateItemsOnLocal([collection])
        }
        
        let collectionOnLocal = self.readItemLocal.fetchCollection(collectionID)
        
        let collectionOnRemote = self.readItemRemote
            .requestLoadCollection(collectionID: collectionID)
            .do(onNext: thenUdateLocal)
                
        return collectionOnLocal.catchAndReturn(nil).compactMap { $0 }.asObservable()
            .concat(collectionOnRemote)
    }
    
    public func requestLoadReadLinkItem(_ itemID: String) -> Observable<ReadLink> {
        
        let linkOnLocal = self.readItemLocal.fetchReadLink(itemID)
        
        let thenUpdateLocal: (ReadLink) -> Void = { [weak self] link in
            self?.updateItemsOnLocal([link])
        }
        let linkOnRemote = self.readItemRemote.requestLoadReadLink(linkID: itemID)
            .do(onNext: thenUpdateLocal)
                
        return linkOnLocal.catchAndReturn(nil).compactMap { $0 }.asObservable()
            .concat(linkOnRemote)
    }
    
    private func updateItemsOnLocal(_ items: [ReadItem]) {
        self.readItemLocal.updateReadItems(items)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        let updateOnRemote = self.readItemRemote.requestUpdateItem(params)
        let updateOnLocal = { [weak self] in self?.readItemLocal.updateItem(params) ?? .empty() }
        return updateOnRemote.switchOr(append: updateOnLocal, witoutError: ())
    }
    
    public func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        
        let findInLocalWithoutError = self.readItemLocal.findLinkItem(using: url)
            .catchAndReturn(nil)
        
        let orFindInRemoteIfNotExistsOnLocal: (ReadLink?) -> Maybe<ReadLink?>
        orFindInRemoteIfNotExistsOnLocal = { [weak self] link in
            guard let self = self else { return .empty() }
            return link.map { .just($0) } ?? self.findLikItemInRemote(url)
        }
        
        return findInLocalWithoutError
            .flatMap(orFindInRemoteIfNotExistsOnLocal)
    }
    
    private func findLikItemInRemote(_ url: String) -> Maybe<ReadLink?> {
        
        let updateLocalIfPossible: (ReadLink?) -> Void = { [weak self] link in
            guard let self = self, let link = link else { return }
            self.readItemLocal.updateReadItems([link])
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.readItemRemote.requestFindLinkItem(using: url)
            .do(onNext: updateLocalIfPossible)
    }
    
    public func requestRemove(item: ReadItem) -> Maybe<Void> {
        
        let removeFromRemote = self.readItemRemote.requestRemoveItem(item)
        let removeFromLocal: () -> Maybe<Void> = { [weak self] in
            return self?.readItemLocal.removeItem(item) ?? .empty()
        }
        
        let thenRemoveLinkMemoIfNeed: () -> Void = { [weak self] in
            self?.removeLinkMemoIfIsLinkItem(item)
        }
        
        return removeFromRemote.switchOr(append: removeFromLocal, witoutError: ())
            .do(onNext: thenRemoveLinkMemoIfNeed)
    }
    
    private func removeLinkMemoIfIsLinkItem(_ item: ReadItem) {
        guard item is ReadLink else { return }
        self.requestRemoveMemo(for: item.uid)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestSuggestNextReadItems(for memberID: String?, size: Int) -> Maybe<[ReadItem]> {
        return memberID
            .map { self.readItemRemote.requestSuggestNextReadItems(for: $0, size: size) }
            ?? self.readItemLocal.suggestNextReadItems(size: size)
    }
    
    public func requestLoadItems(ids: [String]) -> Maybe<[ReadItem]> {
        
        let fetchFromLocal = self.readItemLocal.fetchMathingItems(ids)
        let thenLoadFromRemoteIfNeed: ([ReadItem]) -> Maybe<[ReadItem]> = { [weak self] items in
            return self?.loadItemsFromRemote(ids, alreadyLoad: items) ?? .empty()
        }
        return  fetchFromLocal
            .flatMap(thenLoadFromRemoteIfNeed)
    }
    
    private func loadItemsFromRemote(_ ids: [String], alreadyLoad: [ReadItem]) -> Maybe<[ReadItem]> {
        let localItemsSet = Set(alreadyLoad.map { $0.uid })
        let refreshNeedIDs = ids.filter { localItemsSet.contains($0) == false }
        let refreshItems = refreshNeedIDs.isNotEmpty
            ? self.readItemRemote.requestLoadItems(ids: refreshNeedIDs) : .empty()
        let mergeItems: ([ReadItem]) -> [ReadItem] = { newItems in
            let totalItemsMap = (alreadyLoad + newItems).reduce(into: [String: ReadItem]()) { $0[$1.uid] = $1 }
            return ids.compactMap { totalItemsMap[$0] }
        }
        return refreshItems.ifEmpty(switchTo: .just([]))
            .map(mergeItems)
    }
    
    public func fetchUserReadingLinks() -> Maybe<[ReadLink]> {
        let readingItemIDs = self.readItemLocal.readingLinkItemIDs()
        return self.readItemLocal.fetchMathingItems(readingItemIDs)
            .map { $0.compactMap { $0 as? ReadLink } }
    }
    
    public func updateLinkItemIsReading(_ id: String) {
        self.readItemLocal.updateLinkItemIsReading(id: id, isReading: true)
    }
    
    public func requestRefreshFavoriteItemIDs() -> Observable<[String]> {
        let idsOnLocal = self.readItemLocal.fetchFavoriteItemIDs().catchAndReturn([])
        let updateLocal: ([String]) -> Void = { [weak self] ids in
            guard let self = self else { return }
            self.readItemLocal.replaceFavoriteItemIDs(ids)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        let idsOnRemote = self.readItemRemote.requestLoadFavoriteItemIDs()
            .do(onNext: updateLocal)
        
        return idsOnLocal.asObservable()
            .concat(idsOnRemote)
    }
    
    public func toggleItemIsFavorite(_ id: String, toOn: Bool) -> Maybe<Void> {
        let toggleOnLocal: () -> Maybe<Void> = { [weak self] in
            return self?.readItemLocal.toggleItemIsFavorite(id, isOn: toOn) ?? .empty()
        }
        let toggleOnRemote = self.readItemRemote.requestToggleFavoriteItemID(id, isOn: toOn)
        return toggleOnRemote.switchOr(append: toggleOnLocal, witoutError: ())
    }
    
    public func isReloadNeed() -> Bool {
        return self.readItemLocal.fetchIsReloadCollectionsNeed()
    }
    
    public func updateIsReloadNeed(_ newValue: Bool) {
        return self.readItemLocal.updateIsReloadCollectionNeed(newValue)
    }
}

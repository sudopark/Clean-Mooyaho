//
//  RepositoryImple+ReadItemOptions.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadItemOptionReposiotryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var readItemOptionLocal: ReadItemOptionsLocalStorage {get }
    var readItemOptionRemote: ReadItemOptionsRemote { get }
}

extension ReadItemOptionsRepository where Self: ReadItemOptionReposiotryDefImpleDependency {
    
    public func fetchLastestsIsShrinkModeOn() -> Maybe<Bool?> {
        return self.readItemOptionLocal.fetchReadItemIsShrinkMode()
    }
    
    public func updateLatestIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void> {
        return self.readItemOptionLocal.updateReadItemIsShrinkMode(newvalue)
    }
    
    public func fetchLatestSortOrder() -> Maybe<ReadCollectionItemSortOrder?> {
        return self.readItemOptionLocal.fetchLatestReadItemSortOrder()
    }
    
    public func updateLatestSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return self.readItemOptionLocal.updateLatestReadItemSortOrder(to: newValue)
    }
    
    public func requestLoadCustomOrder(for collectionID: String) -> Observable<[String]> {
        
        let optionOnLocal = self.readItemOptionLocal.fetchReadItemCustomOrder(for: collectionID)
        let optionOnRemote = self.readItemOptionRemote.requestLoadReadItemCustomOrder(for: collectionID)
            .do(onNext: { [weak self] ids in
                guard let self = self, let ids = ids else { return }
                self.readItemOptionLocal.updateReadItemCustomOrder(for: collectionID, itemIDs: ids)
                    .subscribe().disposed(by: self.disposeBag)
            })
        return optionOnLocal.catchAndReturn(nil).asObservable()
            .concat(optionOnRemote)
            .compactMap { $0 }
    }
    
    public func requestUpdateCustomSortOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        let localUpdate = { [weak self] in
            self?.readItemOptionLocal.updateReadItemCustomOrder(for: collectionID, itemIDs: itemIDs) ?? .empty()
        }
        let remoteUpdate = self.readItemOptionRemote.requestUpdateReadItemCustomOrder(for: collectionID, itemIDs: itemIDs)
        return remoteUpdate.switchOr(append: localUpdate, witoutError: ())
    }
    
    public func isAddItemGuideEverShownWithMarking() -> Bool {
        let isShown = self.readItemOptionLocal.isAddItemGuideEverShown()
        if isShown == false {
            self.readItemOptionLocal.markAsAddItemGuideShown()
        }
        return isShown
    }
}

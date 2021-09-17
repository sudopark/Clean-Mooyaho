//
//  LocalStorageImple+ReadItem.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchMyItems() -> Maybe<[ReadItem]> {
        return self.dataModelStorage.fetchMyReadItems()
    }
    
    public func fetchCollectionItems(_ collecitonID: String) -> Maybe<[ReadItem]> {
        return self.dataModelStorage.fetchReadCollectionItems(collecitonID)
    }
    
    public func updateReadItems(_ items: [ReadItem]) -> Maybe<Void> {
        let collections = items.compactMap{ $0 as? ReadCollection }
        let links = items.compactMap{ $0 as? ReadLink }
        let updateCollectionsWithoutError = self.dataModelStorage
            .updateReadCollections(collections).catchAndReturn(())
        
        let thenUpdateLinksWithoutError: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.dataModelStorage.updateReadLinks(links).catchAndReturn(())
        }
        return updateCollectionsWithoutError
            .flatMap(thenUpdateLinksWithoutError)
    }
}

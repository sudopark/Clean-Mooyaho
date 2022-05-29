//
//  SharedDataKeys.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum SharedDataKeys: String {
    case auth
    case currentMember
    case memberMap
    case readItemShrinkIsOn
    case latestReadItemSortOption
    case readItemCustomOrderMap
    case readLinkPreviewMap
    case categoriesMap
    case addSuggestedURLSet
    case latestSharedCollections
    case mySharingCollectionIDs
    case mySharingCollectionMap
    case currentReadingItems
    case favoriteItemIDs
    case saveLastReadPosition
}


extension SharedDataStoreService {
    
    public func save<V>(_ type: V.Type, key: SharedDataKeys, _ v: V) {
        self.update(type, key: key.rawValue, value: v)
    }
    
    public func fetch<V>(_ type: V.Type, key: SharedDataKeys) -> V? {
        return self.get(type, key: key.rawValue)
    }
    
    public func isExists<V>(_ type: V.Type, key: SharedDataKeys,
                            finding: ((V?) -> Bool)? = nil) -> Bool {
        let finding = finding ?? { _ in true }
        let value = self.fetch(type, key: key)
        return finding(value)
    }
}

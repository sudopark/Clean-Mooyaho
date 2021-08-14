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
    case membership
    case memberMap
    case placeMap
}


extension SharedDataStoreService {
    
    public func save<V>(_ type: V.Type, key: SharedDataKeys, _ v: V) {
        self.update(type, key: key.rawValue, value: v)
    }
    
    public func fetch<V>(_ type: V.Type, key: SharedDataKeys) -> V? {
        return self.get(type, key: key.rawValue)
    }
}

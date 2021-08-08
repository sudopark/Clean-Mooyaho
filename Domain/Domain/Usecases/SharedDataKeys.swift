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
}


extension SharedDataStoreService {
    
    public func save<V>(_ key: SharedDataKeys, _ v: V) {
        self.update(key.rawValue, value: v)
    }
    
    public func fetch<V>(_ key: SharedDataKeys) -> V? {
        return self.get(key.rawValue)
    }
}

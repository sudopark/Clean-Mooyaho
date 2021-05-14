//
//  SharedDataKeys.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum SharedDataKeys: String {
    case currentMember
    case membership
}


extension SharedDataStoreService {
    
    public func save<V>(_ key: SharedDataKeys, _ v: V) {
        self.save(key.rawValue, value: v)
    }
    
    public func fetch<V>(_ key: SharedDataKeys) -> V? {
        return self.fetch(key.rawValue)
    }
}

//
//  SharedInbox.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Prelude
import Optics


public struct SharedInbox: Equatable {
    
    public let ownerID: String
    
    public var sharingItemIDs: Set<String> = []
    public var sharedItemIDs: Set<String> = []
    
    public init(ownerID: String) {
        self.ownerID = ownerID
    }
}


extension SharedInbox {
    
    public func insertSharing(itemID: String) -> SharedInbox {
        return self
            |> \.sharingItemIDs %~ { $0 |> elem(itemID) .~ true }
    }
    
    public func insertShared(itemID: String) -> SharedInbox {
        return self
            |> \.sharedItemIDs %~ { $0 |> elem(itemID) .~ true }
    }
    
    public func removeSharing(itemID: String) -> SharedInbox {
        return self
            |> \.sharingItemIDs %~ { $0 |> elem(itemID) .~ false }
    }
    
    public func removeShared(itemID: String) -> SharedInbox {
        return self
            |> \.sharedItemIDs %~ { $0 |> elem(itemID) .~ false }
    }
}

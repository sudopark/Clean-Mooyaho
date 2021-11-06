//
//  ReadLinkMemo.swift
//  Domain
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ReadLinkMemo {
    
    public let linkItemID: String
    public var ownerID: String?
    public var content: String?
    
    public var uuid: String {
        let components = [self.linkItemID, self.ownerID]
        return components.compactMap { $0 }.joined(separator: "-")
    }
    
    public init(itemID: String) {
        self.linkItemID = itemID
    }
}

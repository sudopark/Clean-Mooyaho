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
    public var content: String?
    
    public init(itemID: String) {
        self.linkItemID = itemID
    }
}

//
//  ReadLinkItem.swift
//  Domain
//
//  Created by sudo.park on 2022/07/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct ReadLinkItem: ReadingListItem {
    
    public let uuid: String
    public var customName: String?
    
    public init(uuid: String) {
        self.uuid = uuid
    }
}

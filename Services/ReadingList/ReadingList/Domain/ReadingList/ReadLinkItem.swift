//
//  ReadLinkItem.swift
//  ReadingList
//
//  Created by sudo.park on 2022/06/26.
//

import Foundation


public struct ReadLinkItem: ReadingListItem {
    
    public let uuid: String
    public var customName: String?
    
    public init(uuid: String) {
        self.uuid = uuid
    }
}

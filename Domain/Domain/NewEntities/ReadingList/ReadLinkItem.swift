//
//  ReadLinkItem.swift
//  Domain
//
//  Created by sudo.park on 2022/07/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import Prelude
import Optics
import Extensions


public struct ReadLinkItem: ReadingListItem {
    
    public let uuid: String
    public let link: String
    public var ownerID: String?
    public var createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var customName: String?
    public var categoryIds: [String] = []
    public var priorityID: Int?
    public var isRead: Bool = false
    
    public init(
        uuid: String,
        link: String
    ) {
        self.uuid = uuid
        self.link = link
        self.createdAt = .now()
        self.lastUpdatedAt = .now()
    }
}


extension ReadLinkItem {
    
    private static let uidPrefix = "ri"
    private static var welcomeItemIdentifierPrefix: String { "welcome-item"}
    
    public var isWelcomeItem: Bool {
        return self.uuid.starts(with: Self.welcomeItemIdentifierPrefix)
    }
    
    public static func make(_ link: String) -> ReadLinkItem {
        let uuid = "\(self.uidPrefix):\(UUID().uuidString)"
        return ReadLinkItem(uuid: uuid, link: link)
    }
    
    public static func makeWelcomeItem(_ urlPath: String) -> ReadLinkItem {
        let newUid = "\(welcomeItemIdentifierPrefix)_\(UUID().uuidString)"
        return ReadLinkItem(uuid: newUid, link: urlPath)
            |> \.customName .~ pure("welcome item custom name".localized)
            |> \.priorityID .~ ReadPriority.afterAWhile.rawValue
    }
}

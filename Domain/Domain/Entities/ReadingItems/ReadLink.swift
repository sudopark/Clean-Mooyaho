//
//  ReadLink.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation
import Prelude
import Optics


public struct ReadLink: ReadItem {
    
    private static let uidPrefix = "ri"
    
    public let uid: String
    public var ownerID: String?
    public var parentID: String?
    public let link: String
    public let createdAt: TimeStamp
    public var lastUpdatedAt: TimeStamp
    public var customName: String?
    public var priority: ReadPriority?
    public var categoryIDs: [String] = []
    public var remindTime: TimeStamp?
    public var isRed: Bool = false
    
    public init(uid: String, link: String,
                createAt: TimeStamp, lastUpdated: TimeStamp) {
        self.uid = uid
        self.link = link
        self.createdAt = createAt
        self.lastUpdatedAt = lastUpdated
    }
    
    public init(link: String) {
        self.uid = "\(Self.uidPrefix):\(UUID().uuidString)"
        self.link = link
        self.createdAt = TimeStamp.now()
        self.lastUpdatedAt = TimeStamp.now()
    }
}


extension ReadLink {
    
    private static var welcomeItemIdentifierPrefix: String { "welcome-item"}
    
    public var isWelcomeItem: Bool {
        return self.uid.starts(with: Self.welcomeItemIdentifierPrefix)
    }
    
    public static func makeWelcomeItem(_ urlPath: String) -> ReadLink {
        
        let newUid = "\(welcomeItemIdentifierPrefix)_\(UUID().uuidString)"
        
        return ReadLink(uid: newUid,
                        link: urlPath,
                        createAt: .now(), lastUpdated: .now())
        |> \.customName .~ pure("welcome item custom name".localized)
        |> \.priority .~ .afterAWhile
    }
}

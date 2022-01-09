//
//  HoorayAck+Reaction.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - HoorayAck

public struct HoorayAckInfo {
    
    public let hoorayID: String
    public let ackUserID: String
    public let ackAt: TimeStamp
    
    public init(hoorayID: String, ackUserID: String, ackAt: TimeStamp) {
        self.hoorayID = hoorayID
        self.ackUserID = ackUserID
        self.ackAt = ackAt
    }
}

extension HoorayAckInfo: Hashable {
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.hoorayID == rhs.hoorayID
            && lhs.ackUserID == rhs.ackUserID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hoorayID)
        hasher.combine(self.ackUserID)
    }
}


// MARK: - Reaction & Hooray Reaction

public struct HoorayReaction {
    
    public let hoorayID: String
    public let reactionID: String
    public let reactMemberID: String
    public let icon: ReactionIcon
    public let reactAt: TimeStamp
    
    public init(hoorayID: String,
                reactionID: String,
                reactMemberID: String,
                icon: ReactionIcon,
                reactAt: TimeStamp) {
        self.hoorayID = hoorayID
        self.reactionID = reactionID
        self.reactMemberID = reactMemberID
        self.icon = icon
        self.reactAt = reactAt
    }
}

extension HoorayReaction: Hashable {
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.reactionID == rhs.reactionID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.reactionID)
    }
}

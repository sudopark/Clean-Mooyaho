//
//  HoorayMessages.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - HoorayMessage

public protocol HoorayMessage: Message {
    
    var hoorayID: String { get }
}


// MARK: - NewHoorayMessage

public struct NewHoorayMessage: HoorayMessage {
    
    public let hoorayID: String
    public let publisherID: String
    public let publishedAt: TimeStamp
    
    public let placeID: String?
    public let location: Coordinate
    
    public let spreadDistance: Meters
    public let aliveDuration: TimeInterval
    
    public init(hoorayID: String,
                publisherID: String, publishedAt: TimeStamp,
                placeID: String, location: Coordinate,
                spreadDistance: Meters, aliveDuration: TimeInterval) {
        self.hoorayID = hoorayID
        self.publisherID = publisherID
        self.publishedAt = publishedAt
        self.placeID = placeID
        self.location = location
        self.spreadDistance = spreadDistance
        self.aliveDuration = aliveDuration
    }
    
    public init(new hooray: Hooray) {
        self.hoorayID = hooray.uid
        self.publisherID = hooray.publisherID
        self.publishedAt = hooray.timeStamp
        self.placeID = hooray.placeID
        self.location = hooray.location
        self.spreadDistance = hooray.spreadDistance
        self.aliveDuration = hooray.aliveDuration
    }
}


// MARK: - HoorayAckMessage

public struct HoorayAckMessage: HoorayMessage {
    
    public let hoorayID: String
    public let hoorayPublisherID: String
    public let ackUserID: String
    
    public init(hoorayID: String, publisherID: String, ackUserID: String) {
        self.hoorayID = hoorayID
        self.hoorayPublisherID = publisherID
        self.ackUserID = ackUserID
    }
}


// MARK: - HoorayReactionMessage

public struct HoorayReactionMessage: HoorayMessage {
    
    public let hoorayID: String
    public let hoorayPublisherID: String
    public let reactionInfo: HoorayReaction.ReactionInfo
    
    public init(hoorayID: String, publisherID: String, reactionInfo: HoorayReaction.ReactionInfo) {
        self.hoorayID = hoorayID
        self.hoorayPublisherID = publisherID
        self.reactionInfo = reactionInfo
    }
}

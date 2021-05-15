//
//  Hooray.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Hooray

public struct Hooray {
    
    public let uid: String
    public let placeID: String
    public let publisherID: String
    
    public let location: Coordinate
    public let timeStamp: TimeSeconds
    
    public var ackUserIDs: [String]
    public var reactions: [HoorayReaction.ReactionInfo]
    
    public let spreadDistance: Meters
    public let aliveDuration: TimeInterval
    
    public init(uid: String, placeID: String, publisherID: String,
                location: Coordinate, timestamp: TimeSeconds,
                ackUserIDs: [String] = [], reactions: [HoorayReaction.ReactionInfo],
                spreadDistance: Meters, aliveDuration: TimeInterval) {
        self.uid = uid
        self.placeID = placeID
        self.publisherID = publisherID
        self.location = location
        self.timeStamp = timestamp
        self.ackUserIDs = ackUserIDs
        self.reactions = reactions
        self.spreadDistance = spreadDistance
        self.aliveDuration = aliveDuration
    }
}


// MARK: - New Hooray Form

public struct NewHoorayForm {
    
    public let publisherID: String
        
    // TODO: define fields
}


// MARK: - lastest hooray

public typealias LatestHooray = (id: String, time: TimeSeconds)

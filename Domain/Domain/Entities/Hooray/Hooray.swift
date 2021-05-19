//
//  Hooray.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Hooray

public struct HoorayAckInfo {
    
    public let ackUserID: String
    public let ackAt: TimeStamp
    
    public init(ackUserID: String, ackAt: TimeStamp) {
        self.ackUserID = ackUserID
        self.ackAt = ackAt
    }
}

extension HoorayAckInfo: Hashable {
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.ackUserID == rhs.ackUserID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.ackUserID)
    }
}

extension HoorayReaction.ReactionInfo: Hashable {
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.reactMemberID == rhs.reactMemberID
            && lhs.reactAt == rhs.reactAt
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.reactMemberID)
        hasher.combine(self.reactAt)
    }
}



public struct Hooray {
    
    public let uid: String
    public let placeID: String
    public let publisherID: String
    
    public let location: Coordinate
    public let timeStamp: TimeStamp
    
    public var ackUserIDs: Set<HoorayAckInfo>
    public var reactions: Set<HoorayReaction.ReactionInfo>
    
    public let spreadDistance: Meters
    public let aliveDuration: TimeInterval
    
    public init(uid: String, placeID: String, publisherID: String,
                location: Coordinate, timestamp: TimeStamp,
                ackUserIDs: [HoorayAckInfo] = [], reactions: [HoorayReaction.ReactionInfo],
                spreadDistance: Meters, aliveDuration: TimeInterval) {
        self.uid = uid
        self.placeID = placeID
        self.publisherID = publisherID
        self.location = location
        self.timeStamp = timestamp
        self.ackUserIDs = Set(ackUserIDs)
        self.reactions = Set(reactions)
        self.spreadDistance = spreadDistance
        self.aliveDuration = aliveDuration
    }
}


// MARK: - New Hooray Form

public final class NewHoorayForm {
    
    public let publisherID: String
    public var publisherNickName: String!
    public var placeID: String?
    
    public var location: Coordinate!
    public var timeStamp: TimeStamp!
    
    public var spreadDistance: Meters!
    public var aliveDuration: TimeInterval!
    
    public init(publisherID: String) {
        self.publisherID = publisherID
    }
}

public typealias NewHoorayFormBuilder = Builder<NewHoorayForm>

extension NewHoorayFormBuilder {
    
    public func build() -> Base? {
        let asserting: (NewHoorayForm) -> Bool = { form in
            guard form.publisherNickName != nil,
                  form.location != nil,
                  form.timeStamp != nil,
                  form.spreadDistance != nil,
                  form.aliveDuration != nil else { return false }
            return true
        }
        return self.build(with: asserting)
    }
}


// MARK: - lastest hooray

public typealias LatestHooray = (id: String, time: TimeStamp)

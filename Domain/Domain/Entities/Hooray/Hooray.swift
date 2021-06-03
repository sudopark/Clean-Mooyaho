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
    
    public let hoorayKeyword: String
    public let message: String
    public let tags: [String]
    public let image: ImageSource?
    
    public let location: Coordinate
    public let timeStamp: TimeStamp
    
    public var ackUserIDs: Set<HoorayAckInfo>
    public var reactions: Set<HoorayReaction.ReactionInfo>
    
    public let spreadDistance: Meters
    public let aliveDuration: TimeInterval
    
    public init(uid: String, placeID: String, publisherID: String,
                hoorayKeyword: String, message: String, tags: [String] = [], image:ImageSource? = nil,
                location: Coordinate, timestamp: TimeStamp,
                ackUserIDs: [HoorayAckInfo] = [], reactions: [HoorayReaction.ReactionInfo],
                spreadDistance: Meters, aliveDuration: TimeInterval) {
        self.uid = uid
        self.placeID = placeID
        self.publisherID = publisherID
        self.hoorayKeyword = hoorayKeyword
        self.message = message
        self.tags = tags
        self.image = image
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
    public var placeID: String?
    
    public var hoorayKeyword: String!
    public var message: String!
    public var tags: [String] = []
    public var image: ImageSource?
    
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
            guard form.hoorayKeyword?.isNotEmpty == true,
                  form.message?.isNotEmpty == true,
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

//
//  HoorayAck+Reaction.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - HoorayAck

public typealias HoorayAck = (hoorayID: String, ackUserID: String)


// MARK: - Reaction & Hooray Reaction

public struct HoorayReaction {
    
    public struct ReactionInfo {
        
        public let reactMemberID: String
        public let icon: ImageSource
        public let reactAt: TimeSeconds
        
        public init(reactMemberID: String,
                    icon: ImageSource,
                    reactAt: TimeSeconds) {
            self.reactMemberID = reactMemberID
            self.icon = icon
            self.reactAt = reactAt
        }
    }
    
    public let hoorayID: String
    public let reactionInfo: ReactionInfo
    
    public init(hoorayID: String, reactionInfo: ReactionInfo) {
        self.hoorayID = hoorayID
        self.reactionInfo = reactionInfo
    }
}

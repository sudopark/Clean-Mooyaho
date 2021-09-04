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
    
    
    // MARK: - Keyword
    
    public struct Keyword {
        
        public let uid: String
        public let text: String
        public let soundSource: String?
        
        public init(uid: String, text: String, soundSource: String?) {
            self.uid = uid
            self.text = text
            self.soundSource = soundSource
        }
        
        public static var `default`: Self {
            return Keyword(uid: "default", text: "Hooray", soundSource: nil)
        }
        
        public var isDefault: Bool {
            return self.uid == "default"
        }
    }
    
    public let uid: String
    public let placeID: String?
    public let publisherID: String
    
    public let hoorayKeyword: Keyword
    public let message: String
    public let tags: [String]
    public var image: ImageSource?
    
    public let location: Coordinate
    public let timeStamp: TimeStamp
    
    public let spreadDistance: Meters
    public let aliveDuration: TimeInterval
    
    public init(uid: String, placeID: String?, publisherID: String,
                hoorayKeyword: Keyword, message: String, tags: [String] = [], image:ImageSource? = nil,
                location: Coordinate, timestamp: TimeStamp,
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
        self.spreadDistance = spreadDistance
        self.aliveDuration = aliveDuration
    }
}


// MARK: - New Hooray Form

public final class NewHoorayForm {
    
    public let publisherID: String
    public var placeID: String?
    public var placeName: String?
    
    public var hoorayKeyword: Hooray.Keyword!
    public var message: String!
    public var tags: [String] = []
    public var imagePath: String?
    public var imageSize: ImageSize?
    
    public var location: Coordinate!
    public var timeStamp: TimeStamp!
    
    public var spreadDistance: Meters!
    public var aliveTime: TimeInterval!
    
    public init(publisherID: String) {
        self.publisherID = publisherID
    }
}

public typealias NewHoorayFormBuilder = Builder<NewHoorayForm>

extension NewHoorayFormBuilder {
    
    public func build() -> Base? {
        let asserting: (NewHoorayForm) -> Bool = { form in
            guard form.hoorayKeyword != nil,
                  form.message?.isNotEmpty == true,
                  form.location != nil,
                  form.timeStamp != nil else { return false }
            
            let assertImage = form.imagePath != nil ? form.imageSize != nil : true
            return assertImage
        }
        return self.build(with: asserting)
    }
}


// MARK: - lastest hooray

public typealias LatestHooray = (id: String, time: TimeStamp)


// MARK: - HoorayDetail

public struct HoorayDetail {
    
    public let hoorayInfo: Hooray
    public let acks: [HoorayAckInfo]
    public let reactions: [HoorayReaction]
    
    public init(info: Hooray,
                acks: [HoorayAckInfo],
                reactions: [HoorayReaction]) {
        self.hoorayInfo = info
        self.acks = acks
        self.reactions = reactions
    }
}

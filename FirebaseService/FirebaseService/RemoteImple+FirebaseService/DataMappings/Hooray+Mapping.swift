//
//  Hooray+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/16.
//

import Foundation

import Domain
//import DataStore

enum HoorayMappingKey: String, JSONMappingKeys {
    
    case uid
    case placeID = "plc_id"
    case publisherID = "pub_id"
    
    case keyword = "h_kwd"
    case message = "msg"
    case tags = "tags"
    case image = "img"
    
    case latt = "lat"
    case long = "lng"
    case timestamp = "ts"
    case ackUserIDs = "acks"
    case reactions
    case spreadDistance = "s_dist"
    case aliveDuration = "alive_dur"
    
    case ackUserID = "ack_uid"
    case ackAt = "ack_at"
    
    case reactID = "rct_uid"
    case reactMemberID = "rct_mid"
    case icon = "icon"
    case reactAt = "rct_at"
    
    case geoHash = "geohash"
}

private typealias Key = HoorayMappingKey

extension HoorayAckInfo: JSONMappable {
    
    init?(json: JSON) {
        guard let userID = json[Key.ackUserID] as? String,
              let ackAt = json[Key.ackAt] as? Double else { return nil }
        self.init(ackUserID: userID, ackAt: ackAt)
    }
    
    func asJSON() -> JSON {
        return [
            Key.ackUserID.rawValue: self.ackUserID,
            Key.ackAt.rawValue: self.ackAt
        ]
    }
    
    
}

extension HoorayReaction.ReactionInfo: JSONMappable {
    
    init?(json: JSON) {
        guard let reactID = json[Key.reactID] as? String,
              let memberID = json[Key.reactMemberID] as? String,
              let sourceJSON = json[Key.icon] as? JSON,
              let icon = ImageSource(json: sourceJSON),
              let reactAt = json[Key.reactAt] as? Double else { return nil }
        self.init(reactionID: reactID, reactMemberID: memberID, icon: icon, reactAt: reactAt)
    }
    
    func asJSON() -> JSON {
        return [
            Key.reactID.rawValue: self.reactionID,
            Key.reactMemberID.rawValue: self.reactMemberID,
            Key.icon.rawValue: self.icon.asJSON(),
            Key.reactAt.rawValue: self.reactAt
        ]
    }
    
    
}

extension HoorayReaction: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let info = ReactionInfo(json: json) else { return nil }
        self.init(hoorayID: docuID, reactionInfo: info)
    }
    
    func asDocument() -> (String, JSON) {
        return (self.hoorayID, self.reactionInfo.asJSON())
    }
}



extension Hooray: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let publisherID = json[Key.publisherID] as? String,
              let keyword = json[Key.keyword] as? String,
              let message = json[Key.message] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let time = json[Key.timestamp] as? Double,
              let distance = json[Key.spreadDistance] as? Double,
              let duration = json[Key.aliveDuration] as? Double else {
            return nil
        }
        
        let acksJSONArrray = json[Key.ackUserIDs] as? [JSON]
        let reactionJSONArray = json[Key.reactions] as? [JSON]
        
        let placeID = json[Key.placeID] as? String
        let tags = json[Key.tags] as? [String] ?? []
        let image = (json[Key.image] as? JSON).flatMap(ImageSource.init(json:))
        let coordinate = Coordinate(latt: latt, long: long)
        let acks = acksJSONArrray?.compactMap{ j -> HoorayAckInfo? in .init(json: j) } ?? []
        let reactions = reactionJSONArray?.compactMap{ j -> HoorayReaction.ReactionInfo? in .init(json: j) } ?? []
        
        self.init(uid: docuID, placeID: placeID, publisherID: publisherID,
                  hoorayKeyword: keyword, message: message, tags: tags, image: image,
                  location: coordinate, timestamp: time,
                  ackUserIDs: acks, reactions: reactions,
                  spreadDistance: distance, aliveDuration: duration)
    }
    
    func asDocument() -> (String, JSON) {
        
        let center2D = CLLocationCoordinate2D(latitude: self.location.latt,
                                              longitude: self.location.long)
        let hash = GFUtils.geoHash(forLocation: center2D)
        var json: JSON = [:]
        json[Key.placeID] = self.placeID
        json[Key.publisherID] = self.publisherID
        json[Key.keyword] = self.hoorayKeyword
        json[Key.message] = self.message
        json[Key.tags] = self.tags
        json[Key.image] = self.image?.asJSON
        json[Key.latt] = self.location.latt
        json[Key.long] = self.location.long
        json[Key.timestamp] = self.timeStamp
        json[Key.ackUserIDs] = self.ackUserIDs.map{ $0.asJSON() }
        json[Key.reactions] = self.reactions.map{ $0.asJSON() }
        json[Key.spreadDistance] = self.spreadDistance
        json[Key.aliveDuration] = self.aliveDuration
        json[Key.geoHash] = hash
        return (self.uid, json)
    }
}


extension NewHoorayForm: JSONMappable {
    
    convenience init?(json: JSON) {
        guard let pubID = json[Key.publisherID] as? String,
              let placeID = json[Key.placeID] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let time = json[Key.timestamp] as? Double else { return nil }
        self.init(publisherID: pubID)
        self.placeID = placeID
        self.location = .init(latt: latt, long: long)
        self.timeStamp = time
    }
    
    func asJSON() -> JSON {
        var json: JSON = [:]
        json[Key.publisherID] = self.publisherID
        json[Key.keyword] = self.hoorayKeyword
        json[Key.message] = self.message
        json[Key.latt] = self.location.latt
        json[Key.long] = self.location.long
        json[Key.timestamp] = self.timeStamp
        json[Key.spreadDistance] = self.spreadDistance
        json[Key.aliveDuration] = self.aliveTime
        json[Key.placeID] = self.placeID
        json[Key.tags] = self.tags
        let imageSource = self.imagePath.map{ ImageSource.path($0) }
        json[Key.image] = imageSource?.asJSON
        return json
    }
}


struct HoorayIndex: DocumentMappable {
    
    let hoorayID: String
    let publishedAt: TimeStamp
    
    init(hid: String, at: TimeStamp) {
        self.hoorayID = hid
        self.publishedAt = at
    }
    
    init?(docuID: String, json: JSON) {
        guard let time = json[Key.timestamp] as? TimeStamp else { return nil }
        self.init(hid: docuID, at: time)
    }
    
    func asDocument() -> (String, JSON) {
        return (self.hoorayID, [Key.timestamp.rawValue: self.publishedAt])
    }
}

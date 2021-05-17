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
    case latt = "lat"
    case long = "lng"
    case timestamp = "ts"
    case ackUserIDs = "acks"
    case reactions
    case spreadDistance = "s_dist"
    case aliveDuration = "alive_dur"
    
    case ackUserID = "ack_uid"
    case ackAt = "ack_at"
    
    case reactMemberID = "rct_mid"
    case icon = "icon"
    case reactAt = "rct_at"
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
        guard let memberID = json[Key.reactMemberID] as? String,
              let sourceJSON = json[Key.icon] as? JSON,
              let icon = ImageSource(json: sourceJSON),
              let reactAt = json[Key.reactAt] as? Double else { return nil }
        self.init(reactMemberID: memberID, icon: icon, reactAt: reactAt)
    }
    
    func asJSON() -> JSON {
        return [
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
        guard let placeID = json[Key.placeID] as? String,
              let publisherID = json[Key.publisherID] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let time = json[Key.timestamp] as? Double,
              let acksJSONArrray = json[Key.ackUserIDs] as? [JSON],
              let reactionJSONArray = json[Key.reactions] as? [JSON],
              let distance = json[Key.spreadDistance] as? Double,
              let duration = json[Key.aliveDuration] as? Double else {
            return nil
        }
        
        let coordinate = Coordinate(latt: latt, long: long)
        let acks = acksJSONArrray.compactMap{ j -> HoorayAckInfo? in .init(json: j) }
        let reactions = reactionJSONArray.compactMap{ j -> HoorayReaction.ReactionInfo? in .init(json: j) }
        
        self.init(uid: docuID, placeID: placeID, publisherID: publisherID,
                  location: coordinate, timestamp: time,
                  ackUserIDs: acks, reactions: reactions,
                  spreadDistance: distance, aliveDuration: duration)
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [:]
        json[Key.placeID] = self.placeID
        json[Key.publisherID] = self.publisherID
        json[Key.latt] = self.location.latt
        json[Key.long] = self.location.long
        json[Key.timestamp] = self.timeStamp
        json[Key.ackUserIDs] = self.ackUserIDs.map{ $0.asJSON() }
        json[Key.reactions] = self.reactions.map{ $0.asJSON() }
        json[Key.spreadDistance] = self.spreadDistance
        json[Key.aliveDuration] = self.aliveDuration
        return (self.uid, json)
    }
}


extension NewHoorayForm: JSONMappable {
    
    convenience init?(json: JSON) {
        guard let pubID = json[Key.publisherID] as? String,
              let placeID = json[Key.placeID] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let time = json[Key.timestamp] as? Double,
              let distance = json[Key.spreadDistance] as? Double,
              let duration = json[Key.aliveDuration] as? Double else { return nil }
        self.init(publisherID: pubID)
        self.placeID = placeID
        self.location = .init(latt: latt, long: long)
        self.timeStamp = time
        self.spreadDistance = distance
        self.aliveDuration = duration
    }
    
    func asJSON() -> JSON {
        var json: JSON = [:]
        json[Key.publisherID] = self.publisherID
        json[Key.placeID] = self.placeID
        json[Key.latt] = self.location.latt
        json[Key.long] = self.location.long
        json[Key.timestamp] = self.timeStamp
        json[Key.spreadDistance] = self.spreadDistance
        json[Key.aliveDuration] = self.aliveDuration
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

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
    
    case keywordID = "h_kwd_id"
    case keywordText = "h_kwd_txt"
    case keywordSource = "h_kwd_src"
    
    case message = "msg"
    case tags = "tags"
    case image = "img"
    
    case latt = "lat"
    case long = "lng"
    case timestamp = "ts"
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

extension HoorayAckInfo: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let hoorayID = json[Key.uid] as? String,
              let userID = json[Key.ackUserID] as? String,
              let ackAt = json[Key.ackAt] as? Double else { return nil }
        self.init(hoorayID: hoorayID, ackUserID: userID, ackAt: ackAt)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.uid.rawValue: self.hoorayID,
            Key.ackUserID.rawValue: self.ackUserID,
            Key.ackAt.rawValue: self.ackAt
        ]
        return ("\(self.hoorayID)-\(self.ackUserID)", json)
    }
}

extension HoorayReaction: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let hoorayID = json[Key.uid] as? String,
              let memberID = json[Key.reactMemberID] as? String,
              let iconJSON = json[Key.icon] as? JSON,
              let icon = Thumbnail(json: iconJSON),
              let reactAt = json[Key.reactAt] as? Double else { return nil }
        
        self.init(hoorayID: hoorayID,
                  reactionID: docuID, reactMemberID: memberID,
                  icon: icon, reactAt: reactAt)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.uid.rawValue: self.hoorayID,
            Key.reactMemberID.rawValue: self.reactMemberID,
            Key.icon.rawValue: self.icon.asJSON(),
            Key.reactAt.rawValue: self.reactAt
        ]
        return (self.reactionID, json)
    }
}



extension Hooray: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let publisherID = json[Key.publisherID] as? String,
              let keywordID = json[Key.keywordID] as? String,
              let keywordText = json[Key.keywordText] as? String,
              let message = json[Key.message] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let time = json[Key.timestamp] as? Double,
              let distance = json[Key.spreadDistance] as? Double,
              let duration = json[Key.aliveDuration] as? Double else {
            return nil
        }
        
        let keywordSource = json[Key.keywordSource] as? String
        let keyword = Keyword(uid: keywordID, text: keywordText, soundSource: keywordSource)
        
        let placeID = json[Key.placeID] as? String
        let tags = json[Key.tags] as? [String] ?? []
        let image = (json[Key.image] as? JSON).flatMap(ImageSource.init(json:))
        let coordinate = Coordinate(latt: latt, long: long)
        
        self.init(uid: docuID, placeID: placeID, publisherID: publisherID,
                  hoorayKeyword: keyword, message: message, tags: tags, image: image,
                  location: coordinate, timestamp: time,
                  spreadDistance: distance, aliveDuration: duration)
    }
    
    func asDocument() -> (String, JSON) {
        
        let center2D = CLLocationCoordinate2D(latitude: self.location.latt,
                                              longitude: self.location.long)
        let hash = GFUtils.geoHash(forLocation: center2D)
        var json: JSON = [:]
        json[Key.placeID] = self.placeID
        json[Key.publisherID] = self.publisherID
        json[Key.keywordID] = self.hoorayKeyword.uid
        json[Key.keywordText] = self.hoorayKeyword.text
        json[Key.keywordSource] = self.hoorayKeyword.soundSource
        json[Key.message] = self.message
        json[Key.tags] = self.tags
        json[Key.image] = self.image?.asJSON
        json[Key.latt] = self.location.latt
        json[Key.long] = self.location.long
        json[Key.timestamp] = self.timeStamp
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
        json[Key.keywordID] = self.hoorayKeyword.uid
        json[Key.keywordText] = self.hoorayKeyword.text
        json[Key.keywordSource] = self.hoorayKeyword.soundSource
        json[Key.message] = self.message
        json[Key.latt] = self.location.latt
        json[Key.long] = self.location.long
        json[Key.timestamp] = self.timeStamp
        json[Key.spreadDistance] = self.spreadDistance
        json[Key.aliveDuration] = self.aliveTime
        json[Key.placeID] = self.placeID
        json[Key.tags] = self.tags
        if let path = self.imagePath, let size = self.imageSize {
            json[Key.image] = ImageSource(path: path, size: size)
        }
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

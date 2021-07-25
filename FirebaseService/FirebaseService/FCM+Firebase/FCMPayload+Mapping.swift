//
//  FCMPayload+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/07/25.
//

import Foundation

import Domain


// MARK: - message type & mapping key

protocol PushPayloadMappingKey { }

extension PushPayloadMappingKey {
    
    static var messageTypeKey: String { "m_type" }
}

struct BasePushPayloadMappingKey: PushPayloadMappingKey { }

enum PushMessagingTypes: String {
    case hoorayAck = "hooray_ack"
}


// MARK: - payload mapping

protocol MessagePayloadConvertable {
    
    init?(_ payload: [String: Any])
    
    func asDataPayload() -> [String: Any]
}


extension HoorayAckMessage: MessagePayloadConvertable {
    
    enum MappingKeys: String, PushPayloadMappingKey {
        case hoorayID = "hid"
        case publisherID = "pub_uid"
        case ackUserID = "ack_uid"
    }
    
    init?(_ payload: [String : Any]) {
        let Key = MappingKeys.self
        guard let hoorayID = payload[Key.hoorayID] as? String,
              let publisherID = payload[Key.publisherID] as? String,
              let ackUserID = payload[Key.ackUserID] as? String else {
            return nil
        }
        self.init(hoorayID: hoorayID, publisherID: publisherID, ackUserID: ackUserID)
    }
    
    func asDataPayload() -> [String : Any] {
        let Key = MappingKeys.self
        return [
            Key.messageTypeKey: PushMessagingTypes.hoorayAck.rawValue,
            Key.hoorayID.rawValue: self.hoorayID,
            Key.publisherID.rawValue: self.hoorayPublisherID,
            Key.ackUserID.rawValue: self.ackUserID
        ]
    }
}


private extension Dictionary where Key == String, Value == Any {
    
    subscript<K: PushPayloadMappingKey & RawRepresentable>(key: K) -> Value? where K.RawValue == String {
        get {
            return self[key.rawValue]
        } set {
            self[key.rawValue] = newValue
        }
    }
}

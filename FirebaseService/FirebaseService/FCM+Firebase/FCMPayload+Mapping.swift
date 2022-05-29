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
    case remind
}


// MARK: - payload mapping

protocol MessagePayloadConvertable {
    
    init?(_ payload: [String: Any])
    
    func asDataPayload() -> [String: Any]
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

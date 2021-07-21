//
//  UserDevices.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/19.
//

import Foundation


struct UserDevices {
    
    enum Platform: String {
        case ios
        case android
    }
    
    let deviceID: String
    let userID: String
    let platform: Platform
    let token: String?
    var isOnline: Bool
}


enum UserDeviceMappingKey: String, JSONMappingKeys {
    case userID = "user_id"
    case platform
    case token
    case isOnline
}
fileprivate typealias Key = UserDeviceMappingKey

extension UserDevices: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let userID = json[Key.userID] as? String,
              let platformValue = json[Key.platform] as? String,
              let platform = Platform(rawValue: platformValue),
              let isOnline = json[Key.isOnline] as? Bool else { return nil }
        let token = json[Key.token] as? String
        self.init(deviceID: docuID, userID: userID, platform: platform, token: token, isOnline: isOnline)
    }
    
    func asDocument() -> (String, JSON) {
        var json: JSON = [
            Key.userID.rawValue: self.userID,
            Key.platform.rawValue: self.platform.rawValue,
            Key.isOnline.rawValue: self.isOnline
        ]
        json[Key.token.rawValue] = self.token
        return (self.userID, json)
    }
}

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
    
    let userID: String
    let platform: Platform
    let token: String
    var isOnline: Bool
}


enum UserDeviceMappingKey: String, JSONMappingKeys {
    case platform
    case token
    case isOnline
}
fileprivate typealias Key = UserDeviceMappingKey

extension UserDevices: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let platformValue = json[Key.platform] as? String,
              let platform = Platform(rawValue: platformValue),
              let token = json[Key.token] as? String,
              let isOnline = json[Key.isOnline] as? Bool else { return nil }
        self.init(userID: docuID, platform: platform, token: token, isOnline: isOnline)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.platform.rawValue: self.platform.rawValue,
            Key.token.rawValue: self.token,
            Key.isOnline.rawValue: self.isOnline
        ]
        return (self.userID, json)
    }
}

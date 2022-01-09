//
//  Feedback+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/12/15.
//

import Foundation

import Domain


enum FeedbackMappingKey: String, JSONMappingKeys {
    
    case userID = "user_id"
    case appVersion = "app_version"
    case osVersion = "os_version"
    case deviceModel = "device_model"
    case os
    case contract
    case message
}

private typealias Key = FeedbackMappingKey


extension Feedback: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let userID = json[Key.userID] as? String,
              let appVersion = json[Key.appVersion] as? String,
              let osVersion = json[Key.osVersion] as? String,
              let deviceModel = json[Key.deviceModel] as? String,
              let contract = json[Key.contract] as? String,
              let message = json[Key.message] as? String
        else {
            return nil
        }
        self.init(uuid: docuID, userID: userID)
        self.appVersion = appVersion
        self.osVersion = osVersion
        self.deviceModel = deviceModel
        self.contract = contract
        self.message = message
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.userID.rawValue: self.userID,
            Key.appVersion.rawValue: self.appVersion ?? "",
            Key.osVersion.rawValue: self.osVersion ?? "",
            Key.deviceModel.rawValue: self.deviceModel ?? "",
            Key.contract.rawValue: self.contract ?? "",
            Key.message.rawValue: self.message ?? ""
        ]
        return (self.uuid, json)
    }
    
}

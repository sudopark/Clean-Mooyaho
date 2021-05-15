//
//  Auth+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/09.
//

import Foundation


import Domain
import DataStore


// MARK: - Map ImageSource

extension ImageSource: JSONMappable {
    
    init?(json: JSON) {
        if let pathValue = json["path"] as? String {
            self = .path(pathValue)
            
        } else if let referenceJson = json["reference"] as? [String: Any],
                  let pathValue = referenceJson["path"] as? String {
            let description = referenceJson["description"] as? String
            self = .reference(pathValue, description: description)
            
        } else if let emoji = json["emoji"] as? String {
            self = .emoji(emoji)
            
        }  else {
            return nil
        }
    }
    
    func asJSON() -> JSON {
        switch self {
        case let .path(value):
            return ["path": value]
            
        case let .reference(value, description):
            return ["reference": ["path": value, "description": description]]
            
        case let .emoji(value):
            return ["emoji": value]
        }
    }
}


// MARK: - map memebr

extension Member: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        self.init(uid: docuID)
        self.nickName = json.string(for: "nick_name")
        self.icon = json.childJson(for: "icon").flatMap(ImageSource.init(json:))
    }
    
    func asDocument() -> (String, JSON) {
        var json = JSON()
        json["nick_name"] = self.nickName
        json["icon"] = self.icon?.asJSON
        return (self.uid, json)
    }
}


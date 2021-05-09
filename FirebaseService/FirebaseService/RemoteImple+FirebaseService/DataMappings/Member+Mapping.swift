//
//  Auth+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/09.
//

import Foundation


import Domain
import DataStore


// MARK: - Map Icon

extension DataModels.Icon: JSONMappable {
    
    init?(json: JSON) {
        if let pathValue = json["path"] as? String {
            self.init(path: pathValue)
            
        } else if let referenceJson = json["reference"] as? [String: Any],
                  let pathValue = referenceJson["path"] as? String {
            let description = referenceJson["description"] as? String
            self.init(external: pathValue, description: description)
            
        } else {
            return nil
        }
    }
    
    func asJSON() -> JSON {
        var json = JSON()
        if let path = self.path {
            json["path"] = path
        } else if let external = self.externals {
            var subJSON: JSON = [:]
            subJSON["path"] = external.path
            subJSON["description"] = external.description
            json["reference"] = subJSON
        }
        return json
    }
}


extension ImageSource: JSONMappable {
    
    init?(json: JSON) {
        if let pathValue = json["path"] as? String {
            self = .path(pathValue)
            
        } else if let referenceJson = json["reference"] as? [String: Any],
                  let pathValue = referenceJson["path"] as? String {
            let description = referenceJson["description"] as? String
            self = .reference(pathValue, description: description)
            
        } else {
            return nil
        }
    }
    
    func asJSON() -> JSON {
        switch self {
        case let .path(value):
            return ["path": value]
            
        case let .reference(value, description):
            return ["reference": ["path": value, "description": description]]
        }
    }
}


// MARK: - map memebr

extension DataModels.Member: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        self.init(uid: docuID)
        self.nickName = json.string(for: "nick_name")
        self.icon = json.childJson(for: "icon").flatMap(DataModels.Icon.init(json:))
    }
    
    func asDocument() -> (String, JSON) {
        var json = JSON()
        json["nick_name"] = self.nickName
        json["icon"] = self.icon?.asJSON
        return (self.uid, json)
    }
}


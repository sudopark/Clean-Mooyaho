//
//  DataMapping.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation

import Domain
import DataStore



typealias JSON = [String: Any]

extension JSON {
    
    func childJson(for key: String) -> JSON? {
        return self[key] as? JSON
    }
    
    func string(for key: String) -> String? {
        return self[key] as? String
    }
}


// MARK: - map member


extension DataModels.Icon {
    
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
}

extension DataModels.Member {
    
    init(docuID: String, json: JSON) {
        self.init(uid: docuID)
        self.nickName = json.string(for: "nick_name")
        self.icon = json.childJson(for: "icon").flatMap(DataModels.Icon.init(json:))
    }
}

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

protocol JSONMappable {
    
    init?(json: JSON)
}

extension JSON {
    
    func childJson(for key: String) -> JSON? {
        return self[key] as? JSON
    }
    
    func string(for key: String) -> String? {
        return self[key] as? String
    }
}


// MARK: - map member


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
}

extension DocumentSnapshot {
    
    
    func asMember() -> Member? {
        
        guard let json = self.data() else { return nil }
        var customer = Customer(memberID: self.documentID)
        customer.nickName = json.string(for: "nickName")
        customer.icon = json.childJson(for: "icon").flatMap(ImageSource.init(json:))
        return customer
    }
}

//
//  Tag+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/10.
//

import Foundation

import Domain
import DataStore


extension ReqParams.Tag: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let typeValue = json["type"] as? String,
              let type = TagType(rawValue: typeValue) else { return nil }
        self.init(type: type, keyword: docuID)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = ["type": self.tagType.rawValue]
        return (self.keyword, json)
    }
}

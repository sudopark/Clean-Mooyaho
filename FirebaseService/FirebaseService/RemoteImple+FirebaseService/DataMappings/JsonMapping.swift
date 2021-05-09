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

protocol JSONMappable {
    
    init?(json: JSON)
    
    func asJSON() -> JSON
}

protocol DocumentMappable {

    init?(docuID: String, json: JSON)
    
    func asDocument() -> (String, JSON)
}

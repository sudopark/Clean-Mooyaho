//
//  FavoriteReadingListItem+Mapping.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/15.
//

import Foundation

import Remote


enum FavoriteMappingKey: String {
    case ownerID
    case ids
}

struct MemberFavoriteListItem: JsonConvertable {
    
    private typealias Keys = FavoriteMappingKey
    
    let ownerID: String
    let ids: [String]
    
    init(ownerID: String, ids: [String]) {
        self.ownerID = ownerID
        self.ids = ids
    }
    
    static var identifierKey: String { Keys.ownerID.rawValue }
    var identifier: String { self.ownerID }
    
    init(json: [String : Any]) throws {
        let ownerID: String = try json.value(Keys.ownerID)
        self.ownerID = ownerID
        self.ids = try json.value(Keys.ids)
    }
    
    func asJson() -> [String : Any] {
        return [
            Keys.ownerID.rawValue: self.ownerID,
            Keys.ids.rawValue: self.ids
        ]
    }
}

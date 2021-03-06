//
//  ShareItem+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/14.
//

import Foundation

import Prelude
import Optics

import Domain


// MARK: - SharedInbox

struct SharedInbox: Equatable {
    
    let ownerID: String
    var sharingCollectionIDs: [String] = []
    var sharedIDs: [String] = []
    
    init(ownerID: String) {
        self.ownerID = ownerID
    }
    
    func insertSharing(_ id: String) -> SharedInbox {
        return self
            |> \.sharingCollectionIDs %~ { [id] + $0.filter { $0 != id } }
    }
    
    func removedSharing(_ id: String) -> SharedInbox {
        return self
            |> \.sharingCollectionIDs %~ { $0.filter { $0 != id} }
    }
    
    func insertShared(_ id: String) -> SharedInbox {
        return self
            |> \.sharedIDs %~ { [id] + $0.filter { $0 != id } }
    }
    
    func removedShared(_ id: String) -> SharedInbox {
        return self
            |> \.sharedIDs %~ { $0.filter { $0 != id } }
    }
}



// MARK: - mapping

enum ShareItemMappingKey: String, JSONMappingKeys {
    
    case ownerID = "oid"
    
    // for collection
    case collectionID = "cid"
    
    // for inbox
    case sharing
    case shared
}

private typealias Key = ShareItemMappingKey

extension SharingCollectionIndex: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let ownerID = json[Key.ownerID] as? String,
              let collectionID = json[Key.collectionID] as? String
        else {
            return nil
        }
        self.init(shareID: docuID, ownerID: ownerID, collectionID: collectionID)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.ownerID.rawValue: self.ownerID,
            Key.collectionID.rawValue: self.collectionID
        ]
        return (self.shareID, json)
    }
}

extension SharedInbox: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        self.init(ownerID: docuID)
        self.sharingCollectionIDs = json[Key.sharing] as? [String] ?? []
        self.sharedIDs = json[Key.shared] as? [String] ?? []
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.sharing.rawValue: self.sharingCollectionIDs,
            Key.shared.rawValue: self.sharedIDs
        ]
        return (self.ownerID, json)
    }
}

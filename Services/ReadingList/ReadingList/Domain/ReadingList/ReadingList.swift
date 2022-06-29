//
//  ReadingList.swift
//  ReadingList
//
//  Created by sudo.park on 2022/06/26.
//

import Foundation

import Prelude
import Optics
import Extensions


// MARK: - ReadingListItem

public protocol ReadingListItem  {
    
    var uuid: String { get }
}



// MARK: - ReadingList

public struct ReadingList: ReadingListItem {
    
    public let uuid: String
    public let ownerID: String
    public let isRootList: Bool
    public var name: String
    public var createdAt: TimeInterval
    public var lastUpdatedAt: TimeInterval
    public var description: String?
    
    public var items: [ReadingListItem] = []
    
    public init(
        uuid: String,
        name: String,
        ownerID: String,
        isRootList: Bool = false
    ) {
        self.uuid = uuid
        self.ownerID = ownerID
        self.isRootList = isRootList
        self.name = name
        self.createdAt = .now()
        self.lastUpdatedAt = .now()
    }
}


// MARK: - make list

extension ReadingList {
    
    private static var rootListID: String { "root_collection" }
    private static var rootListName: String { "root_collection" }
    
    public static func makeList(_ name: String, ownerID: String) -> ReadingList {
        let uuid = UUID().uuidString
        return .init(uuid: uuid, name: name, ownerID: ownerID, isRootList: false)
    }
    
    public static func makeMyRootList(_ ownerID: String) -> ReadingList {
        return .init(uuid: self.rootListID, name: self.rootListName, ownerID: ownerID, isRootList: true)
    }
}


// MARK: - update list item

extension ReadingList {
    
    public func appendItem(_ item: ReadingListItem) -> ReadingList {
        return self
            |> \.items %~ { $0 + [item] }
    }
    
    public func updateItem(_ newItem: ReadingListItem) throws -> ReadingList {
        guard let index = self.items.firstIndex(where: { $0.uuid == newItem.uuid })
        else {
            throw RuntimeError("item not exists on list")
        }
        let newList = self.items |> ix(index) .~ newItem
        return self |> \.items .~ newList
    }
    
    public func updateItem(itemID: String,
                           _ mutating: (ReadingListItem) -> ReadingListItem) throws -> ReadingList {
        guard let index = self.items.firstIndex(where: { $0.uuid == itemID })
        else {
            throw RuntimeError("item not exists on list")
        }
        let newItem = mutating(self.items[index])
        let newList = self.items |> ix(index) .~ newItem
        return self |> \.items .~ newList
    }
    
    public func removeItem(_ itemID: String) throws -> ReadingList {
        guard let index = self.items.firstIndex(where: { $0.uuid == itemID })
        else {
            throw RuntimeError("item not exists on list")
        }
        var newList = self.items
        newList.remove(at: index)
        return self |> \.items .~ newList
    }
}

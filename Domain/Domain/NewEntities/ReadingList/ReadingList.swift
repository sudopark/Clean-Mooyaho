//
//  ReadingList.swift
//  ReadingList
//
//  Created by sudo.park on 2022/06/26.
//

import Foundation

import Prelude
import Optics


// MARK: - ReadingListItem

public protocol ReadingListItem: Sendable  {
    
    var uuid: String { get }
    var parentID: String? { get set }
}



// MARK: - ReadingList

public struct ReadingList: ReadingListItem {
    
    public let uuid: String
    public var ownerID: String?
    public var parentID: String?
    public let isRootList: Bool
    public var name: String
    public var createdAt: TimeInterval
    public var lastUpdatedAt: TimeInterval
    public var description: String?
    public var categoryIds: [String] = []
    public var priorityID: Int?
    
    public var items: [ReadingListItem] = []
    
    public init(
        uuid: String,
        name: String,
        isRootList: Bool = false
    ) {
        self.uuid = uuid
        self.isRootList = isRootList
        self.name = name
        self.createdAt = .now()
        self.lastUpdatedAt = .now()
    }
}


// MARK: - make list

extension ReadingList {
    
    static let uidPrefix = "rc"
    public static var rootListID: String { "root_collection" }
    private static var rootListName: String { "root_collection" }
    
    public static func makeList(_ name: String, ownerID: String) -> ReadingList {
        let uuid = "\(self.uidPrefix):\(UUID().uuidString)"
        return .init(uuid: uuid, name: name, isRootList: false)
            |> \.ownerID .~ ownerID
    }
    
    public static func makeMyRootList(_ ownerID: String?) -> ReadingList {
        return .init(uuid: self.rootListID, name: self.rootListName, isRootList: true)
            |> \.ownerID .~ ownerID
    }
}

extension String {
    
    public var isListID: Bool {
        return self.starts(with: ReadingList.uidPrefix)
    }
}

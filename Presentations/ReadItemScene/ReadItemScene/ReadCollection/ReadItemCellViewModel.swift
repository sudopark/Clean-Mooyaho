//
//  ReadItemCellViewModel.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import Domain


// MARK: - ReadItemCellViewModel

public protocol ReadItemCellViewModel {
    var uid: String { get }
    
    var presetingID: Int { get }
    var categoryIDs: [String] { get set }
}


// MARK: - ReadCollectionSectionCellViewModel

public struct ReadCollectionAttrCellViewModel: ReadItemCellViewModel {
    
    public var uid: String { "collection_attr" }
    public var collectionDescription: String?
    public var presetingID: Int { self.uid.hashValue }
    
    public var priority: ReadPriority?
    public var categoryIDs: [String] = []
    
    public init(collection: ReadCollection) {
        self.priority = collection.priority
        self.categoryIDs = collection.categoryIDs
    }
}


// MARK: - ReadCollectionCellViewModel

public struct ReadCollectionCellViewModel: ReadItemCellViewModel {
    
    public let uid: String
    public let name: String
    public var collectionDescription: String?
    public var priority: ReadPriority?
    public var categoryIDs: [String] = []
    
    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
    
    public init(collection: ReadCollection) {
        self.uid = collection.uid
        self.name = collection.name
        self.priority = collection.priority
        self.categoryIDs = collection.categoryIDs
        self.collectionDescription = collection.collectionDescription
    }

    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categoryIDs)
        hasher.combine(self.collectionDescription)
        return hasher.finalize()
    }
}


// MARK: - ReadLinkCellViewModel

public struct ReadLinkCellViewModel: ReadItemCellViewModel {
    
    public let uid: String
    public let linkUrl: String
    public var customName: String?
    public var priority: ReadPriority?
    public var categoryIDs: [String] = []
    
    public init(uid: String, linkUrl: String) {
        self.uid = uid
        self.linkUrl = linkUrl
    }
    
    public init(link: ReadLink) {
        self.uid = link.uid
        self.linkUrl = link.link
        self.customName = link.customName
        self.priority = link.priority
        self.categoryIDs = link.categoryIDs
    }
    
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.linkUrl)
        hasher.combine(self.customName)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categoryIDs)
        return hasher.finalize()
    }
}

private extension ItemCategory {
    
    func presentingHashValud() -> Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}

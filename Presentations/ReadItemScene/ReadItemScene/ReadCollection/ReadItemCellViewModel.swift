//
//  ReadItemCellViewModel.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import Domain
import CommonPresenting


// MARK: - ReadCollectionSectionCellViewModel

public protocol ReadCollectionItemCellViewMdoelType: ReadItemCellViewModelType {
    
    var remind: ReadRemind? { get set }
}

public struct ReadCollectionAttrCellViewModel: ReadCollectionItemCellViewMdoelType {
    
    public typealias Item = ReadCollection
    
    public var uid: String { "collection_attr" }
    public var collectionDescription: String?
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.collectionDescription)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categories.map { $0.presentingHashValue() })
        hasher.combine(self.remind?.presentingHasValue())
        return hasher.finalize()
    }
    
    public var priority: ReadPriority?
    public var categories: [ItemCategory] = []
    public var remind: ReadRemind?
    
    public init(item: ReadCollection) {
        self.priority = item.priority
        self.collectionDescription = item.collectionDescription
    }
}


// MARK: - ReadCollectionCellViewModel

protocol ShrinkableCell {
    var isShrink: Bool { get set }
}

public struct ReadCollectionCellViewModel: ReadCollectionItemCellViewMdoelType, ShrinkableCell {
    
    public typealias Item = ReadCollection
    
    public let uid: String
    public let name: String
    public var collectionDescription: String?
    public var priority: ReadPriority?
    public var categories: [ItemCategory] = []
    var isShrink = false
    public var remind: ReadRemind?
    
    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
    
    public init(item: ReadCollection) {
        self.uid = item.uid
        self.name = item.name
        self.priority = item.priority
        self.collectionDescription = item.collectionDescription
    }

    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categories.map { $0.presentingHashValue() })
        hasher.combine(self.collectionDescription)
        hasher.combine(self.isShrink)
        hasher.combine(self.remind?.presentingHasValue())
        return hasher.finalize()
    }
}


// MARK: - ReadLinkCellViewModel

public struct ReadLinkCellViewModel: ReadCollectionItemCellViewMdoelType, ShrinkableCell {
    
    public typealias Item = ReadLink
    
    public let uid: String
    public let linkUrl: String
    public var customName: String?
    public var priority: ReadPriority?
    public var categories: [ItemCategory] = []
    var isShrink = false
    public var remind: ReadRemind?
    
    public init(uid: String, linkUrl: String) {
        self.uid = uid
        self.linkUrl = linkUrl
    }
    
    public init(item: ReadLink) {
        self.uid = item.uid
        self.linkUrl = item.link
        self.customName = item.customName
        self.priority = item.priority
    }
    
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.linkUrl)
        hasher.combine(self.customName)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categories.map { $0.presentingHashValue() })
        hasher.combine(self.isShrink)
        hasher.combine(self.remind?.presentingHasValue())
        return hasher.finalize()
    }
}

private extension ItemCategory {
    
    func presentingHashValue() -> Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}

private extension ReadRemind {
    
    func presentingHasValue() -> Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.itemID)
        hasher.combine(self.scheduledTime)
        return hasher.finalize()
    }
}

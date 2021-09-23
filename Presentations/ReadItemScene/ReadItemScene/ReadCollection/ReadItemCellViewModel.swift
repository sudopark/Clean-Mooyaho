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
    var isShrink: Bool { get set }
    
    var presetingID: Int { get }
}


// MARK: - ReadCollectionSectionCellViewModel

public struct ReadCollectionSectionCellViewModel: ReadItemCellViewModel {
    
    public let title: String
    public var uid: String { self.title }
    public var isShrink: Bool = false
    public var presetingID: Int { self.uid.hashValue }
}


// MARK: - ReadCollectionCellViewModel

public struct ReadCollectionCellViewModel: ReadItemCellViewModel {
    
    public let uid: String
    public let name: String
    public var priority: ReadPriority?
    public var categories: [ItemCategory] = []
    public var isShrink: Bool = false
    
    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
    
    public init(collection: ReadCollection) {
        self.uid = collection.uid
        self.name = collection.name
        self.priority = collection.priority
        self.categories = collection.categories
    }

    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categories.map{ $0.presentingHashValud() })
        hasher.combine(self.isShrink)
        return hasher.finalize()
    }
}


// MARK: - ReadLinkCellViewModel

public struct ReadLinkCellViewModel: ReadItemCellViewModel {
    
    public let uid: String
    public let linkUrl: String
    public var customName: String?
    public var priority: ReadPriority?
    public var categories: [ItemCategory] = []
    public var isShrink: Bool = false
    
    public init(uid: String, linkUrl: String) {
        self.uid = uid
        self.linkUrl = linkUrl
    }
    
    public init(link: ReadLink) {
        self.uid = link.uid
        self.linkUrl = link.link
        self.customName = link.customName
        self.priority = link.priority
        self.categories = link.categories
    }
    
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.linkUrl)
        hasher.combine(self.customName)
        hasher.combine(self.priority?.rawValue)
        hasher.combine(self.categories.map{ $0.presentingHashValud() })
        hasher.combine(self.isShrink)
        return hasher.finalize()
    }
}

private extension ItemCategory {
    
    func presentingHashValud() -> Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}

//
//  SharedCollectionItemsViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


protocol LikePresentable {
    
    var likeCount: Int { get set }
    var iLike: Bool { get set }
}


// MARK: - CellViewModels

public struct SharedCollectionAttrCellViewModel: ReadItemCellViewModelType, LikePresentable {
    
    public typealias Item = ReadCollection
    
    public var uid: String { "collection_attr" }
    public var collectionDescription: String?
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.collectionDescription)
        hasher.combine(self.categories.map { $0.presentingHashValue() })
        hasher.combine(self.likeCount)
        hasher.combine(self.iLike)
        return hasher.finalize()
    }
    
    public var categories: [ItemCategory] = []
    var likeCount: Int = 0
    var iLike: Bool = false
    
    public init(item: ReadCollection) {
        self.collectionDescription = item.collectionDescription
        self.remindTime = item.remindTime
    }
}

public struct SharedCollectionCellViewModel: ReadItemCellViewModelType, ShrinkableCell, LikePresentable {
    
    public typealias Item = ReadCollection
    
    public let uid: String
    public let name: String
    public var collectionDescription: String?
    public var categories: [ItemCategory] = []
    public var isShrink = false
    var likeCount: Int = 0
    var iLike: Bool = false
    
    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
    
    public init(item: ReadCollection) {
        self.uid = item.uid
        self.name = item.name
        self.collectionDescription = item.collectionDescription
    }

    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.categories.map { $0.presentingHashValue() })
        hasher.combine(self.collectionDescription)
        hasher.combine(self.isShrink)
        hasher.combine(self.likeCount)
        hasher.combine(self.iLike)
        return hasher.finalize()
    }
}


// MARK: - ReadLinkCellViewModel

public struct SharedLinkCellViewModel: ReadItemCellViewModelType, ShrinkableCell, LikePresentable {
    
    public typealias Item = ReadLink
    
    public let uid: String
    public let linkUrl: String
    public var customName: String?
    public var categories: [ItemCategory] = []
    public var isShrink = false
    var likeCount: Int = 0
    var iLike: Bool = false
    
    public init(uid: String, linkUrl: String) {
        self.uid = uid
        self.linkUrl = linkUrl
    }
    
    public init(item: ReadLink) {
        self.uid = item.uid
        self.linkUrl = item.link
        self.customName = item.customName
    }
    
    public var presetingID: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.linkUrl)
        hasher.combine(self.customName)
        hasher.combine(self.categories.map { $0.presentingHashValue() })
        hasher.combine(self.isShrink)
        hasher.combine(self.likeCount)
        hasher.combine(self.iLike)
        return hasher.finalize()
    }
}


// MARK: - SharedCollectionItemsViewModel

public protocol SharedCollectionItemsViewModel: AnyObject {

    // interactor
    func reloadCollectionSubItems()
    func openItem(_ itemID: String)
    func viewDidAppear()
    
    // presenter
    var collectionTitle: Observable<String> { get }
    var sections: Observable<[ReadCollectionItemSection]> { get }
    func linkPreview(for linkID: String) -> Observable<LinkPreview>
}


// MARK: - SharedCollectionItemsViewModelImple

public final class SharedCollectionItemsViewModelImple: SharedCollectionItemsViewModel {
    
    private let router: SharedCollectionItemsRouting
    private weak var listener: SharedCollectionItemsSceneListenable?
    
    public init(router: SharedCollectionItemsRouting,
                listener: SharedCollectionItemsSceneListenable?) {
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
//        let currentCollection = BehaviorSubject<ReadCollection?>(value: nil)
//        let sortOrder = BehaviorRelay<ReadCollectionItemSortOrder?>(value: nil)
//        let collections = BehaviorRelay<[ReadCollection]?>(value: nil)
//        let links = BehaviorRelay<[ReadLink]?>(value: nil)
//        let categoryMap = BehaviorSubject<[String: ItemCategory]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SharedCollectionItemsViewModelImple Interactor

extension SharedCollectionItemsViewModelImple {
    
    
    public func reloadCollectionSubItems() {
        
    }
    
    public func openItem(_ itemID: String) {
        
    }
    
    public func viewDidAppear() {
        
    }
}


// MARK: - SharedCollectionItemsViewModelImple Presenter

extension SharedCollectionItemsViewModelImple {
    
    public var collectionTitle: Observable<String> {
        return .empty()
    }
    
    public var sections: Observable<[ReadCollectionItemSection]> {
        return .empty()
    }
    
    public func linkPreview(for linkID: String) -> Observable<LinkPreview> {
        return .empty()
    }
}

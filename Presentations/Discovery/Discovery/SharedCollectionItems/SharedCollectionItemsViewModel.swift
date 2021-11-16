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
import Prelude
import Optics

import Domain
import CommonPresenting


protocol LikePresentable {
    
    var likeCount: Int { get set }
    var iLike: Bool { get set }
}


// MARK: - CellViewModels

public struct SharedCollectionAttrCellViewModel: ReadItemCellViewModelType, LikePresentable {
    
    public typealias Item = SharedReadCollection
    
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
    
    public init(item: SharedReadCollection) {
        self.collectionDescription = item.description
        self.remindTime = item.remindTime
    }
}

public struct SharedCollectionCellViewModel: ReadItemCellViewModelType, ShrinkableCell, LikePresentable {
    
    public typealias Item = SharedReadCollection
    
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
    
    public init(item: SharedReadCollection) {
        self.uid = item.uid
        self.name = item.name
        self.collectionDescription = item.description
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
    
    public typealias Item = SharedReadLink
    
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
    
    public init(item: SharedReadLink) {
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
    
    private let loadSharedCollectionUsecase: SharedReadCollectionLoadUsecase
    private let linkPreviewLoadUsecase: ReadLinkPreviewLoadUsecase
    private let readItemOptionsUsecase: ReadItemOptionsUsecase
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: SharedCollectionItemsRouting
    private weak var listener: SharedCollectionItemsSceneListenable?
    private weak var navigationListener: ReadCollectionNavigateListenable?
    
    public init(currentCollection: SharedReadCollection,
                loadSharedCollectionUsecase: SharedReadCollectionLoadUsecase,
                linkPreviewLoadUsecase: ReadLinkPreviewLoadUsecase,
                readItemOptionsUsecase: ReadItemOptionsUsecase,
                categoryUsecase: ReadItemCategoryUsecase,
                router: SharedCollectionItemsRouting,
                listener: SharedCollectionItemsSceneListenable?,
                navigationListener: ReadCollectionNavigateListenable) {
        
        self.loadSharedCollectionUsecase = loadSharedCollectionUsecase
        self.linkPreviewLoadUsecase = linkPreviewLoadUsecase
        self.readItemOptionsUsecase = readItemOptionsUsecase
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
        self.navigationListener = navigationListener
        self.subjects = .init(collection: currentCollection)
        
        self.bindRequireCategories()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let currentCollection: BehaviorRelay<SharedReadCollection>
        let collections = BehaviorRelay<[SharedReadCollection]?>(value: nil)
        let links = BehaviorRelay<[SharedReadLink]?>(value: nil)
        let categoryMap = BehaviorSubject<[String: ItemCategory]>(value: [:])
        init(collection: SharedReadCollection) {
            self.currentCollection = .init(value: collection)
        }
    }
    
    private let subjects: Subjects
    private let disposeBag = DisposeBag()
    
    private func totalItemSomeIDSet(_ extracting: @escaping ([ReadItem]) -> [String]) -> Observable<Set<String>> {
        let totalItems: Observable<[ReadItem]> = Observable.merge(
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            self.subjects.currentCollection.compactMap { $0 }.map { [$0] }
        )
        let foldAsSet: (Set<String>, [ReadItem]) -> Set<String> = { acc, items in
            let newIDs = extracting(items)
            return acc.union(newIDs)
        }
        return totalItems.scan(Set<String>(), accumulator: foldAsSet)
    }
    
    private func bindRequireCategories() {

        let categoryIDSet = self.totalItemSomeIDSet { $0.flatMap { $0.categoryIDs } }
        let loadCategories: (Set<String>) -> Observable<[ItemCategory]> = { [weak self] idSet in
            guard let self = self else { return .empty() }
            return self.categoryUsecase.categories(for: Array(idSet))
        }
        categoryIDSet
            .distinctUntilChanged()
            .flatMapLatest(loadCategories)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] categories in
                let dict = categories.reduce(into: [String: ItemCategory]()) { $0[$1.uid] = $1 }
                self?.subjects.categoryMap.onNext(dict)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SharedCollectionItemsViewModelImple Interactor

extension SharedCollectionItemsViewModelImple {
    
    
    public func reloadCollectionSubItems() {
        let updateList: ([SharedReadItem]) -> Void = { [weak self] itemes in
            let collections = itemes.compactMap{ $0 as? SharedReadCollection }
            let links = itemes.compactMap{ $0 as? SharedReadLink }
            self?.subjects.collections.accept(collections)
            self?.subjects.links.accept(links)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        let collectionID = self.subjects.currentCollection.value.uid
        self.loadSharedCollectionUsecase.loadSharedCollectionSubItems(collectionID: collectionID)
            .subscribe(onSuccess: updateList, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func openItem(_ itemID: String) {
        let totalItems: [SharedReadItem] = (self.subjects.collections.value ?? []) + (self.subjects.links.value ?? [])
        guard let item = totalItems.first(where: { $0.uid == itemID }) else { return }
        switch item {
        case let collectionItem as SharedReadCollection:
            self.router.moveToSubCollection(collection: collectionItem)
            
        case let linkItem as SharedReadLink:
            self.router.showLinkDetail(linkItem)
            
        default: break
        }
    }
    
    public func viewDidAppear() {
        let collectionID = self.subjects.currentCollection.value.uid
        self.navigationListener?.readCollection(didShowShared: collectionID)
    }
}


// MARK: - SharedCollectionItemsViewModelImple Presenter

extension SharedCollectionItemsViewModelImple {
    
    public var collectionTitle: Observable<String> {
        return self.subjects.currentCollection
            .map { $0.name }
            .distinctUntilChanged()
    }
    
    public var sections: Observable<[ReadCollectionItemSection]> {
        let asSections: (
            SharedReadCollection, [SharedReadCollection], [SharedReadLink],
            [String: ItemCategory], Bool
        ) ->  [ReadCollectionItemSection]
        asSections = { currentCollection, collections, links, cateMap, isShrinkMode in
            
            let attributeCell = SharedCollectionAttrCellViewModel(item: currentCollection)
                |> \.categories .~ currentCollection.categoryIDs.compactMap{ cateMap[$0] }
            
            let collectionCells: [SharedCollectionCellViewModel] = collections
                .asCellViewModels(with: cateMap)
                .updateIsShrinkMode(isShrinkMode)
            
            let linkCells: [SharedLinkCellViewModel] = links
                .asCellViewModels(with: cateMap)
                .updateIsShrinkMode(isShrinkMode)
            
            let sections: [ReadCollectionItemSection?] =  [
                [attributeCell].asSectionIfNotEmpty(for: .attribute),
                collectionCells.asSectionIfNotEmpty(for: .collections),
                linkCells.asSectionIfNotEmpty(for: .links)
            ]
            return sections.compactMap { $0 }
        }
        
        return Observable.combineLatest(
            self.subjects.currentCollection,
            self.subjects.collections.compactMap { $0 },
            self.subjects.links.compactMap { $0 },
            self.subjects.categoryMap,
            self.readItemOptionsUsecase.isShrinkModeOn,
            resultSelector: asSections
        )
    }
    
    public func linkPreview(for linkID: String) -> Observable<LinkPreview> {
        let links = self.subjects.links.value
        guard let linkItem = links?.first(where: { $0.uid == linkID }) else {
            return .empty()
        }
        return self.linkPreviewLoadUsecase.loadLinkPreview(linkItem.link)
    }
}

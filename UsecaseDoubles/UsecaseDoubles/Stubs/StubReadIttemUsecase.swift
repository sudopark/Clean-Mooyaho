//
//  StubReadIttemUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import RxSwift

import Domain

open class StubReadItemUsecase: ReadItemUsecase, ReadItemSyncUsecase {
    
    public struct Scenario {
        public var myItems: Result<[ReadItem], Error> = .success([])
        public var collectionInfo: Result<ReadCollection, Error> = .success(.dummy(0))
        public var collectionItems: Result<[ReadItem], Error> = .success([])
        public var collectionItemsStream: [[ReadItem]]?
        public var updateCollectionResult: Result<Void, Error> = .success(())
        public var updateLinkResult: Result<Void, Error> = .success(())
        public var refreshedSortOrder: Result<ReadCollectionItemSortOrder, Error> = .success(.default)
        public var customOrder: Result<[String], Error> = .success([])
        public var updateCustomOrderResult: Result<Void, Error> = .success(())
        public var shrinkModeIsOn: Bool = false
        public var preview: Result<LinkPreview, Error> = .success(.dummy(0))
        public var sortOption: [ReadCollectionItemSortOrder] = [.default]
        public var loadReadLinkResult: Result<ReadLink, Error> = .success(.dummy(0))
        
        public var suggestNextResult: Result<[ReadItem], Error> = .success([])
        public var loadContinueLinks: Result<[ReadLink], Error> = .success([])
        public var loadFavoriteIDsResult: Result<[String], Error> = .success([])
        public var isAddIttemGuideEverShown: Bool = false
        public var isWelcomeItemAddedBefore: Bool = false
        
        public init() {}
    }
    public var scenario: Scenario
    private let disposeBag = DisposeBag()
    public init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    public var reloadNeedCollectionIDsMocking: [String] = []
    public var reloadNeedCollectionIDs: [String] {
        get { self.reloadNeedCollectionIDsMocking }
        set { self.reloadNeedCollectionIDsMocking = newValue }
    }
    
    open func loadMyItems() -> Observable<[ReadItem]> {
        return self.scenario.myItems.asMaybe().asObservable()
    }
    
    open func loadCollectionInfo(_ collectionID: String) -> Observable<ReadCollection> {
        return self.scenario.collectionInfo.asMaybe().asObservable()
    }
    
    public var didLoadCollectionItemsCount: Int = 0
    open func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        return self.scenario.collectionItems.asMaybe().asObservable()
            .do(onNext: { _ in
                self.didLoadCollectionItemsCount += 1
            })
    }
    
    public func loadReadLink(_ linkID: String) -> Observable<ReadLink> {
        return self.scenario.loadReadLinkResult.asMaybe().asObservable()
    }
    
    open func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        return self.scenario.updateCollectionResult.asMaybe()
            .do(onNext: {
                self.readItemUpdateMocking.onNext(.updated(newCollection))
            })
    }
    
    open func updateLink(_ link: ReadLink) -> Maybe<Void> {
        return self.scenario.updateLinkResult.asMaybe()
            .do(onNext: {
                self.readItemUpdateMocking.onNext(.updated(link))
            })
    }
    
    private var fakeIsShrinkMode = PublishSubject<Bool>()
    open var isShrinkModeOn: Observable<Bool> {
        return self.fakeIsShrinkMode
            .startWith(self.scenario.shrinkModeIsOn)
    }
    
    open func updateLatestIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
        self.scenario.shrinkModeIsOn = newvalue
        self.fakeIsShrinkMode.onNext(newvalue)
        return .just()
    }
    
    open func loadLatestSortOption() -> Maybe<ReadCollectionItemSortOrder> {
        return self.scenario.refreshedSortOrder.asMaybe()
    }
    
    open var sortOrder: Observable<ReadCollectionItemSortOrder> {
        return Observable.from(self.scenario.sortOption)
    }
    
    open func updateLatestSortOption(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        return .empty()
    }
    
    open func reloadCustomOrder(for collectionID: String) -> Observable<[String]> {
        return self.scenario.customOrder.asMaybe().asObservable()
            .do(onNext: { [weak self] ids in
                self?.fakeOrders.onNext(ids)
            })
    }
    
    private let fakeOrders = BehaviorSubject<[String]?>(value: nil)
    open func customOrder(for collectionID: String) -> Observable<[String]> {
        return self.fakeOrders.compactMap { $0 }
    }
    
    open func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        return self.scenario.updateCustomOrderResult.asMaybe()
    }
    
    open func loadLinkPreview(_ url: String) -> Observable<LinkPreview> {
        return self.scenario.preview.asMaybe().asObservable()
    }
    
    public var didUpdated: ReadItemUpdateParams?
    open func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        self.didUpdated = params
        let item = params.applyChanges()
        return .just().do(onNext: {
            self.readItemUpdateMocking.onNext(.updated(item))
        })
    }
    
    public var didMarkIsReadingLink: ReadLink?
    public func updateLinkIsReading(_ link: ReadLink) {
        self.didMarkIsReadingLink = link
    }
    
    public func updateLinkItemMark(_ link: ReadLink, asRead: Bool) -> Maybe<Void> {
        var params = ReadItemUpdateParams(item: link)
        params.updatePropertyParams = [.isRed(asRead)]
        return self.updateItem(params)
    }
    
    public let readItemUpdateMocking = PublishSubject<ReadItemUpdateEvent>()
    public var readItemUpdated: Observable<ReadItemUpdateEvent> {
        return self.readItemUpdateMocking.asObservable()
    }
    
    public func removeItem(_ item: ReadItem) -> Maybe<Void> {
        return .just()
    }
    
    public func suggestNextReadItem(size: Int) -> Maybe<[ReadItem]> {
        return self.scenario.suggestNextResult.asMaybe()
    }
    
    public func continueReadingLinks() -> Observable<[ReadLink]> {
        return self.scenario.loadContinueLinks.asMaybe().asObservable()
    }
    
    public func loadReadItems(for itemIDs: [String]) -> Maybe<[ReadItem]> {
        let items = itemIDs.map { ReadCollection(uid: $0, name: "name", createdAt: .now(), lastUpdated: .now())}
        return .just(items)
    }
    
    private let fakeFavoriteItemIDs = BehaviorSubject<[String]>(value: [])
    public func refreshSharedFavoriteIDs() {
        self.refreshFavoriteIDs()
            .subscribe(onNext: {
                self.fakeFavoriteItemIDs.onNext($0)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func refreshFavoriteIDs() -> Observable<[String]> {
        return self.scenario.loadFavoriteIDsResult.asMaybe().asObservable()
    }
    
    public func toggleFavorite(itemID: String, toOn: Bool) -> Maybe<Void> {
        return .just()
            .do(onNext: {
                let ids = (try? self.fakeFavoriteItemIDs.value()) ?? []
                let newIDs = ids.filter { $0 != itemID } + (toOn ? [itemID] : [])
                self.fakeFavoriteItemIDs.onNext(newIDs)
            })
    }
    
    public var sharedFavoriteItemIDs: Observable<[String]> {
        return self.fakeFavoriteItemIDs
            .asObservable()
    }
    
    public func isAddItemGuideEverShownWithMarking() -> Bool {
        return self.scenario.isAddIttemGuideEverShown
    }
    
    public func didWelComeItemAdded() -> Bool {
        return self.scenario.isWelcomeItemAddedBefore
    }
    
    public func updateDidWelcomeItemAdded() {
        self.scenario.isWelcomeItemAddedBefore = true
    }
}

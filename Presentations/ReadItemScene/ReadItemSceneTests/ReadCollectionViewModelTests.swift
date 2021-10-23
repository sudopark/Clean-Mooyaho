//
//  ReadCollectionViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/09/19.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UsecaseDoubles
import UnitTestHelpKit

@testable import ReadItemScene


class ReadCollectionViewModelTests: BaseTestCase,  WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: FakeRouter!
    private var isShrinkModeMocking: ((Bool) -> Void)?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private var dummySubCollections: [ReadCollection] {
        return (0..<5).map { int -> ReadCollection in
            return ReadCollection.dummy(int)
                |> \.priority .~ ReadPriority.makeDummy(int)
        }
    }
    
    private var dummySubLinks: [ReadLink] {
        return (5..<10).map { int -> ReadLink in
            return ReadLink.dummy(int)
                |> \.priority .~ ReadPriority.makeDummy(int)
        }
    }
    
    private var dummyCollectionItems: [ReadItem] {
        return self.dummySubCollections + self.dummySubLinks
    }
    
    func makeViewModel(isRootCollection: Bool = false,
                       shouldFailReload: Bool = false,
                       sortOrder: ReadCollectionItemSortOrder = .default,
                       customOrder: [String] = [],
                       reminds: [ReadRemind] = []) -> ReadCollectionViewItemsModelImple {
        let reloadResult: Result<[ReadItem], Error> = shouldFailReload
            ? .failure(ApplicationErrors.invalid)
            : .success(self.dummyCollectionItems)
        let scenario = StubReadItemUsecase.Scenario()
            |> \.collectionItems .~ reloadResult
            |> \.sortOption .~ [sortOrder]
            |> \.customOrder .~ .success(customOrder)
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        self.isShrinkModeMocking = { newValue in
            stubUsecase.updateLatestIsShrinkModeIsOn(newValue)
                .subscribe().disposed(by: self.disposeBag)
        }
        
        let categoryScenario = StubItemCategoryUsecase.Scenario()
            |> \.categories .~ [(0..<10).map { .dummy($0) }]
        let stubCategoryUsecase = StubItemCategoryUsecase(scenario: categoryScenario)
        
        let remindSceneaio = StubReadRemindUsecase.Scenario()
            |> \.reminds .~ .success(reminds)
        let stubRemindUsecase = StubReadRemindUsecase(scenario: remindSceneaio)
        
        let router = FakeRouter()
        self.spyRouter = router
        
        let collectionID = isRootCollection ? nil : "some"
        let viewModel =  ReadCollectionViewItemsModelImple(collectionID: collectionID,
                                                           readItemUsecase: stubUsecase,
                                                           categoryUsecase: stubCategoryUsecase,
                                                           remindUsecase: stubRemindUsecase,
                                                           router: router)
        router.interactor = viewModel
        return viewModel
    }
    
}

// MAARK: - show item list

extension ReadCollectionViewModelTests {
    
    // load collection items
    func testViewModel_whenReload_shwoCollectionItems() {
        // given
        let expect = expectation(description: "reload시에 collection item 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        let collections = cvms?.compactMap { $0 as? ReadCollectionCellViewModel }
        let links = cvms?.compactMap { $0 as? ReadLinkCellViewModel }
        XCTAssertEqual(collections?.count, 5)
        XCTAssertEqual(links?.count, 5)
    }
    
    func testViewModel_whenNotRootCollecitonAndLoadCollectionInfoEnd_showAttrCell() {
        // given
        let expect = expectation(description: "최상위 루트가 아니면 해당 콜렉션 정보 노출")
        let viewModel = self.makeViewModel(isRootCollection: false)
        
        // when
        let attrs = self.waitFirstElement(expect, for: viewModel.attributeCell) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        XCTAssertEqual(attrs?.count, 1)
    }
    
    func testViewModel_whenRootCollection_notShowAtrributeCell() {
        // given
        let expect = expectation(description: "최상위 루트가 아니면 해당 콜렉션 정보 노출")
        let viewModel = self.makeViewModel(isRootCollection: true)
        
        // when
        let attrs = self.waitFirstElement(expect, for: viewModel.attributeCell) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        XCTAssertEqual(attrs?.count, 0)
    }
    
    func testViewModel_whenAfterLoadItemsFail_showRetryError() {
        // given
        let expect = expectation(description: "reload 실패이후 실패 표시")
        let viewModel = self.makeViewModel(shouldFailReload: true)
        
        self.spyRouter.called(key: "alertError") { _ in
            expect.fulfill()
        }
        // when
        viewModel.reloadCollectionItems()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

// MAARK: - change order

extension ReadCollectionViewModelTests {
    
    func testViewModel_showCurrentOrder() {
        // given
        let expect = expectation(description: "현재 정렬옵션 노출")
        let viewModel = self.makeViewModel(sortOrder: .byCustomOrder)
        
        // when
        let order = self.waitFirstElement(expect, for: viewModel.currentSortOrder)
        
        // then
        XCTAssertEqual(order, .byCustomOrder)
    }
    
    func testViewModel_requestChangeOrders() {
        // given
        let expect = expectation(description: "정렬옵션 변경 요청")
        let viewModel = self.makeViewModel(sortOrder: .byCustomOrder)
        
        self.spyRouter.called(key: "showItemSortOrderOptions") { any in
            if let order = any as? ReadCollectionItemSortOrder, order == .byCustomOrder {
                expect.fulfill()
            }
        }
        // when
        viewModel.requestChangeOrder()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenAfterSelectNewOrder_updateCurrentOrder() {
        // given
        let expect = expectation(description: "정렬옵션 변경")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(sortOrder: .byCustomOrder)
        
        // when
        let orders = self.waitElements(expect, for: viewModel.currentSortOrder) {
            self.spyRouter.mockSelectedNewOrder = .byLastUpdatedAt(false)
            viewModel.requestChangeOrder()
        }
        
        // then
        XCTAssertEqual(orders, [.byCustomOrder, .byLastUpdatedAt(false)])
    }
    
    private var defaultItemIDs: [String] {
        return self.dummyCollectionItems.map{ $0.uid }
    }
    
    private var reversedDefaultItemIDs: [String] {
        return self.dummySubCollections.reversed().map{ $0.uid }
            + self.dummySubLinks.reversed().map{ $0.uid }
    }
    
    func testViewModel_orderByCreated() {
        // given
        let expect = expectation(description: "추가된 날짜로 정렬")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(sortOrder: .byCreatedAt(false))
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels.withoutAttrCell()) {
            viewModel.reloadCollectionItems()
            
            self.spyRouter.mockSelectedNewOrder = .byCreatedAt(true)
            viewModel.requestChangeOrder()
        }
        
        // then
        let itemIDLists = cvmLists.map{ $0.map{ $0.uid }}
        XCTAssertEqual(itemIDLists, [ self.reversedDefaultItemIDs, self.defaultItemIDs ])
    }
    
    func testViewModel_orderByLastUpdatedTime() {
        // given
        let expect = expectation(description: "마지막 수정 날짜로 정렬")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(sortOrder: .byLastUpdatedAt(false))
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels.withoutAttrCell()) {
            viewModel.reloadCollectionItems()
            
            self.spyRouter.mockSelectedNewOrder = .byLastUpdatedAt(true)
            viewModel.requestChangeOrder()
        }
        
        // then
        let itemIDLists = cvmLists.map{ $0.map{ $0.uid }}
        XCTAssertEqual(itemIDLists, [ self.reversedDefaultItemIDs, self.defaultItemIDs ])
    }
    
    func testViewModel_orderByPriority() {
        // given
        let expect = expectation(description: "우선순위로 정렬")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(sortOrder: .byPriority(false))
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels.withoutAttrCell()) {
            viewModel.reloadCollectionItems()
            
            self.spyRouter.mockSelectedNewOrder = .byPriority(true)
            viewModel.requestChangeOrder()
        }
        
        // then
        let itemIDLists = cvmLists.map{ $0.map{ $0.uid }}
        XCTAssertEqual(itemIDLists, [
            ["c:4", "c:3", "c:2", "c:1", "c:0", "l:7", "l:6", "l:5", "l:8", "l:9"],
            ["c:1", "c:2", "c:3", "c:4", "c:0", "l:5", "l:6", "l:7", "l:8", "l:9"]
        ])
    }
    
    func testViewMdoel_orderByCustomOrder() {
        // given
        let expect = expectation(description: "커스텀 정렬 옵션으로 정렬")
        let customOrder = ["c:2", "c:1", "c:4", "c:0", "c:3", "l:9", "l:6", "l:7", "l:8", "l:5"]
        let viewModel = self.makeViewModel(sortOrder: .byCustomOrder, customOrder: customOrder)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels.withoutAttrCell()) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        let itemIDLists = cvms?.map{ $0.uid }
        XCTAssertEqual(itemIDLists, customOrder)
    }
    
    func testViewModel_whenCustomOrderNotExistItem_placeFrontAtOrderedItems() {
        // given
        let expect = expectation(description: "커스텀 오더에 없는 항목은 해당 섹션의 맨 앞에 위치")
        let customOrder = ["c:2", "c:1", "c:4", "c:0", "c:3", "l:9", "l:6", "l:8", "l:5"]
        let viewModel = self.makeViewModel(sortOrder: .byCustomOrder, customOrder: customOrder)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels.withoutAttrCell()) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        let itemIDLists = cvms?.map{ $0.uid }
        XCTAssertEqual(itemIDLists, ["c:2", "c:1", "c:4", "c:0", "c:3", "l:7", "l:9", "l:6", "l:8", "l:5"])
    }
    
    func testViewModel_whenCustomOrderNotExistItem_placeFrontAtOrderedItemsAndSortByCreatedDescending() {
        // given
        let expect = expectation(description: "커스텀 오더에 없는 항목은 해당 섹션의 맨 앞에 위치")
        let customOrder = ["c:2", "c:1", "c:4", "l:9", "l:6", "l:7", "l:8", "l:5"]
        let viewModel = self.makeViewModel(sortOrder: .byCustomOrder, customOrder: customOrder)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels.withoutAttrCell()) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        let itemIDLists = cvms?.map{ $0.uid }
        XCTAssertEqual(itemIDLists, ["c:3", "c:0", "c:2", "c:1", "c:4", "l:9", "l:6", "l:7", "l:8", "l:5"])
    }
}


extension ReadCollectionViewModelTests {
    
    func testViewModel_whenIsShrinkModeUpdated_updateCell() {
        // given
        let expect = expectation(description: "isShrink모드 변경시에 셀 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
            self.isShrinkModeMocking?(true)
        }
        
        // then
        let isShrinks1 = cvms.first?.compactMap { $0 as? ShrinkableCell }.map { $0.isShrink }
        let isShrinks2 = cvms.last?.compactMap { $0 as? ShrinkableCell }.map { $0.isShrink }
        XCTAssertEqual(isShrinks1, Array(repeating: false, count: 10))
        XCTAssertEqual(isShrinks2, Array(repeating: true, count: 10))
    }
}


// MARK: - provide reminds info

extension ReadCollectionViewModelTests {
    
    func testViewModel_provideItemCellViewMdoels_withRemindInfo() {
        // given
        let expect = expectation(description: "remind 정보와 함께 remind 정보 제공")
        let reminds: [ReadRemind] = self.dummyReminderHasItemIDs.map { ReadRemind(uid: "rm:\($0)", itemID: $0, scheduledTime: .now() + 1000) }
        let viewModel = self.makeViewModel(reminds: reminds)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        let remindCollections = cvms?.compactMap { ($0 as? ReadCollectionCellViewModel)?.remind }
        let remindLinks = cvms?.compactMap { ($0 as? ReadLinkCellViewModel)?.remind }
        let remindIDs = (remindCollections?.map { $0.itemID } ?? []) + (remindLinks?.map { $0.itemID } ?? [])
        XCTAssertEqual(remindIDs, self.dummyReminderHasItemIDs)
    }
    
    func testViewModel_excludeExpiredReminds() {
        // given
        let expect = expectation(description: "이미 지난 remind는 제외")
        let reminds: [ReadRemind] = self.dummyReminderHasItemIDs.enumerated().map {
            let offfset: TimeStamp = $0.offset == 0 ? 1000 : -1000
            return ReadRemind(uid: "rm:\($0.offset)", itemID: $0.element, scheduledTime: .now() + offfset)
        }
        let viewModel = self.makeViewModel(reminds: reminds)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
        }
        
        // then
        let remindCollections = cvms?.compactMap { ($0 as? ReadCollectionCellViewModel)?.remind }
        let remindLinks = cvms?.compactMap { ($0 as? ReadLinkCellViewModel)?.remind }
        let remindIDs = (remindCollections?.map { $0.itemID } ?? []) + (remindLinks?.map { $0.itemID } ?? [])
        XCTAssertEqual(remindIDs, ["c:0"])
    }
}

// MAARK: - provide thumbnail

extension ReadCollectionViewModelTests {
    
    
    func testViewMoel_provideLinkPreview() {
        // given
        let expect = expectation(description: "link preview 제공")
        let viewModel = self.makeViewModel()
        viewModel.reloadCollectionItems()
        
        // when
        let load = viewModel.readLinkPreview(for: "l:8")
        let preview = self.waitFirstElement(expect, for: load)
        
        // then
        XCTAssertNotNil(preview)
    }
}

// MAARK: - show detail

extension ReadCollectionViewModelTests {
    
    func testViewModel_moveToSubCollection() {
        // given
        let expect = expectation(description: "collection으로 이동")
        let viewModel = self.makeViewModel()
        viewModel.reloadCollectionItems()
        
        self.spyRouter.called(key: "moveToSubCollection") { _ in
            expect.fulfill()
        }
        
        // when
        let collectionID = self.dummySubCollections.first?.uid ?? "some"
        viewModel.openItem(collectionID)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_showLinkDetail() {
        // given
        let expect = expectation(description: "link 상세 노출")
        let viewModel = self.makeViewModel()
        viewModel.reloadCollectionItems()
        
        self.spyRouter.called(key: "showLinkDetail") { _ in
            expect.fulfill()
        }
        
        // when
        let linkID = self.dummySubLinks.first?.uid ?? "some"
        viewModel.openItem(linkID)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


// MARK: - make collection or add link item

extension ReadCollectionViewModelTests {
    
    private var newCollection: ReadCollection {
        return ReadCollection(uid: "new-collection",
                              name: "new collection", createdAt: .now(),
                              lastUpdated: .now())
            |> \.parentID .~ "some"
    }
    
    private var newLinkItem: ReadLink {
        return ReadLink(uid: "new-link", link: "new link",
                        createAt: .now(), lastUpdated: .now())
            |> \.parentID .~ "some"
    }
    
    func testViewModel_whenAfterMakeNewCollection_appendItemAndReload() {
        // given
        let expect = expectation(description: "콜렉션 생성이후 아이템 추가해서 리로드")
        let viewModel = self.makeViewModel(isRootCollection: false)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels.withoutAttrCell(), skip: 1) {
            viewModel.reloadCollectionItems()
            
            self.spyRouter.mockNewCollection = self.newCollection
            viewModel.addNewCollectionItem()
        }
        
        // then
        XCTAssertEqual(cvms?.count, self.dummyCollectionItems.count + 1)
        XCTAssertEqual(cvms?.first?.uid, self.newCollection.uid)
    }
    
    func testViewModel_whenAfterAddLink_appendItemAndReload() {
        // given
        let expect = expectation(description: "읽기링크 추가 이후 아이템 추가해서 리로드")
        let viewModel = self.makeViewModel(sortOrder: .byCreatedAt(false))
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels.withoutAttrCell(), skip: 1) {
            viewModel.reloadCollectionItems()
            
            self.spyRouter.mockNewLink = self.newLinkItem
            viewModel.addNewReadLinkItem()
        }
        
        // then
        let linkCells = cvms?.compactMap{ $0 as? ReadLinkCellViewModel }
        XCTAssertEqual(cvms?.count, self.dummyCollectionItems.count + 1)
        XCTAssertEqual(linkCells?.first?.uid, self.newLinkItem.uid)
    }
}

// MARK: - context menu

extension ReadCollectionViewModelTests {
    
    func testViewModel_supportContextMenuForCollectionAndLinkItem() {
        // given
        let expect = expectation(description: "collection과 link 아이템에 대하여 컨텍스트 메뉴 제공")
        let viewModel = self.makeViewModel(isRootCollection: false)
        
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
        }
        
        // when
        let collectionCell = cvms?.compactMap { $0 as? ReadCollectionCellViewModel }.first
        let linkCell = cvms?.compactMap { $0 as? ReadLinkCellViewModel }.first
        
        // then
        let collecttionTrailing = viewModel.contextAction(for: collectionCell!, isLeading: false)
        let linkTrailing = viewModel.contextAction(for: linkCell!, isLeading: false)
        XCTAssertEqual(collecttionTrailing, [.delete, .edit])
        XCTAssertEqual(linkTrailing, [.delete, .edit])
    }
    
    private var dummyReminderHasItemIDs: [String] {
        return [self.dummySubCollections.first?.uid, self.dummySubLinks.first?.uid].compactMap { $0 }
    }
    
    func testViewModel_supportLeadingContentMenuForItems() {
        // given
        let expect = expectation(description: "아이템에 대하여 리딩 컨텍스트 메뉴 제공")
        let reminds = self.dummyReminderHasItemIDs.map { ReadRemind(uid: "rm:\($0)", itemID: $0, scheduledTime: .now() + 1000) }
        let viewModel = self.makeViewModel(isRootCollection: false, reminds: reminds)
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
        }
        
        // when
        let collectionCell = cvms?.compactMap { $0 as? ReadCollectionCellViewModel }
                .first(where: { $0.remind != nil })
        let collectionNoRemindCell = cvms?.compactMap { $0 as? ReadCollectionCellViewModel }
                .first(where: { $0.remind == nil })
        let linkCell = cvms?.compactMap { $0 as? ReadLinkCellViewModel }
            .first(where: { $0.remind != nil })
        let linkNotRemindCell = cvms?.compactMap { $0 as? ReadLinkCellViewModel }
            .first(where: { $0.remind == nil })
        
        let collectionLeading = viewModel.contextAction(for: collectionCell!, isLeading: true)
        let collectionLeadingWithoutRemind = viewModel.contextAction(for: collectionNoRemindCell!, isLeading: true)
        let linkLeading = viewModel.contextAction(for: linkCell!, isLeading: true)
        let linkLeadingWithoutRemind = viewModel.contextAction(for: linkNotRemindCell!, isLeading: true)
        
        // then
        XCTAssertEqual(collectionLeading, [.remind(isOn: true)])
        XCTAssertEqual(collectionLeadingWithoutRemind, [.remind(isOn: false)])
        XCTAssertEqual(linkLeading, [.remind(isOn: true)])
        XCTAssertEqual(linkLeadingWithoutRemind, [.remind(isOn: false)])
    }
    
    func testViewModel_editCollectionItem() {
        // given
        let expect = expectation(description: "collection item 수정하고 업데이트")
        let viewModel = self.makeViewModel()
        
        let collection = (self.dummyCollectionItems.first as? ReadCollection)!
            |> \.parentID .~ "some"
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.reloadCollectionItems()
            let newCollection = collection |> \.collectionDescription .~ "new description"
            self.spyRouter.mockNewCollection = newCollection
            viewModel.handleContextAction(for: ReadCollectionCellViewModel(item: collection),
                                             action: .edit)
        }
        
        // then
        let collection1 = cvms?
            .compactMap { $0 as? ReadCollectionCellViewModel }
            .first(where: { $0.uid == collection.uid })
        XCTAssertEqual(collection1?.collectionDescription, "new description")
    }
    
    func testViewModel_editLinkItem() {
        // given
        let expect = expectation(description: "link 아이템 수정하고 업데이트")
        let viewModel = self.makeViewModel()
        
        let link = (self.dummyCollectionItems.compactMap { $0 as? ReadLink }.first)!
            |> \.parentID .~ "some"
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.reloadCollectionItems()
            let newLink = link |> \.categoryIDs .~ ["c:3"]
            self.spyRouter.mockNewLink = newLink
            viewModel.handleContextAction(for: ReadLinkCellViewModel(item: link),
                                             action: .edit)
        }
        
        // then
        let link1 = cvms?
            .compactMap { $0 as? ReadLinkCellViewModel }
            .first(where: { $0.uid == link.uid })
        XCTAssertEqual(link1?.categories.map { $0.uid }, ["c:3"])
    }
    
    // TODO: delete
    
    func testViewModel_requestAddNewRemind() {
        // given
        let expect = expectation(description: "새로운 알림 생성 요청")
        let viewModel = self.makeViewModel()
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
        }
        
        // when
        let cvm = cvms?.filter { ($0 is ReadCollectionAttrCellViewModel) == false }
            .first(where: { $0.remind == nil })
        viewModel.handleContextAction(for: cvm!, action: .remind(isOn: false))
        
        // then
        XCTAssertNotNil(self.spyRouter.didSetupRemindRequestedItem)
    }
    
    func testViewModel_cancelRemind() {
        // given
        let expect = expectation(description: "리마인드 취소")
        expect.expectedFulfillmentCount = 2
        let dummyRemind = ReadRemind.dummy(itemID: self.dummySubCollections.first!.uid, time: .now() + 1000)
        let viewModel = self.makeViewModel(reminds: [dummyRemind])
        
        // when
        let cvms = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
            
            let cvm = ReadCollectionCellViewModel(item: self.dummySubCollections.first!)
                |> \.remind .~ dummyRemind
            viewModel.handleContextAction(for: cvm, action: .remind(isOn: true))
        }
        
        // then
        let cellWithRemindCounts = cvms.map { $0.filter{ $0.remind != nil }.count }
        XCTAssertEqual(cellWithRemindCounts, [1, 0])
    }
}


extension ReadCollectionViewModelTests {
    
    func testViewModel_whenRootCollection_isOrderchangable() {
        // given
        let expect = expectation(description: "루트 콜렉션은 순서변경만 가능")
        let viewModel = self.makeViewModel(isRootCollection: true)
        
        // when
        let editable = self.waitFirstElement(expect, for: viewModel.isEditable) {
            viewModel.reloadCollectionItems()
        }
        viewModel.editCollection()
        
        // then
        XCTAssertEqual(editable, true)
        XCTAssertEqual(
            self.spyRouter.alertRequestedActions?.map { $0.text },
            ["Change order".localized, "Cancel".localized]
        )
    }
    
    func testViewModel_whenIsNotRootCollection_editCollectionChangeOrderAndDeletable() {
        // given
        let expect = expectation(description: "루트 콜렉션이 아니면 편집, 순서변경, 삭제 가능")
        let viewModel = self.makeViewModel(isRootCollection: false)
        
        // when
        let editable = self.waitFirstElement(expect, for: viewModel.isEditable) {
            viewModel.reloadCollectionItems()
        }
        viewModel.editCollection()
        
        // then
        XCTAssertEqual(editable, true)
        XCTAssertEqual(
            self.spyRouter.alertRequestedActions?.map { $0.text },
            ["Edit collection".localized, "Change order".localized, "Delete".localized, "Cancel".localized]
        )
    }
    
    func testViewModel_requestChangeCustomOrder() {
        // given
        let viewModel = self.makeViewModel(isRootCollection: false)
        viewModel.reloadCollectionItems()
        
        // when
        self.spyRouter.mockSelectActionTitle = "Change order".localized
        viewModel.editCollection()
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveEditCustomOrder, true)
    }
}


extension ReadCollectionViewModelTests {
    
    class FakeRouter: ReadCollectionRouting, Mocking {
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
        
        weak var interactor: ReadCollectionItemsSceneInteractable?
        
        var mockSelectedNewOrder: ReadCollectionItemSortOrder?
        
        func showItemSortOrderOptions(_ currentOrder: ReadCollectionItemSortOrder,
                                      selectedHandler: @escaping (ReadCollectionItemSortOrder) -> Void) {
            self.verify(key: "showItemSortOrderOptions", with: currentOrder)
            guard let mock = mockSelectedNewOrder else { return }
            selectedHandler(mock)
        }
        
        func moveToSubCollection(collectionID: String) {
            self.verify(key: "moveToSubCollection")
        }
        
        func showLinkDetail(_ link: ReadLink) {
            self.verify(key: "showLinkDetail")
        }
        
        var mockNewCollection: ReadCollection?
        func routeToMakeNewCollectionScene(at collectionID: String?) {
            guard let mock = self.mockNewCollection else { return }
            interactor?.editReadCollection(didChange: mock)
        }
        
        func routeToEditCollection(_ collection: ReadCollection) {
            guard let mock = self.mockNewCollection else { return }
            interactor?.editReadCollection(didChange: mock)
        }
        
        var mockNewLink: ReadLink?
        func routeToAddNewLink(at collectionID: String?) {
            guard let mock = self.mockNewLink else { return }
            self.interactor?.addReadLink(didAdded: mock)
        }
        
        func routeToEditReadLink(_ link: ReadLink) {
            guard let mock = self.mockNewLink else { return }
            self.interactor?.editReadLink(didEdit: mock)
        }
        
        var alertRequestedActions: [ActionSheetForm.Action]?
        var mockSelectActionTitle: String?
        func alertActionSheet(_ form: ActionSheetForm) {
            self.alertRequestedActions = form.actions
            if let action = form.actions.first(where: { $0.text == mockSelectActionTitle }) {
                action.selected?()
            }
        }
        
        var didMoveEditCustomOrder: Bool?
        func roueToEditCustomOrder(for collectionID: String?) {
            self.didMoveEditCustomOrder = true
        }
        
        var didSetupRemindRequestedItem: ReadItem?
        func routeToSetupRemind(for item: ReadItem) {
            self.didSetupRemindRequestedItem = item
        }
        
        func alertForConfirm(_ form: AlertForm) {
            form.confirmed?()
        }
    }
}

private extension Observable where Element == [ReadItemCellViewModel] {
    
    func withoutAttrCell() -> Observable {
        return self.map {
            return $0.filter{ $0 is ReadCollectionCellViewModel || $0 is ReadLinkCellViewModel }
        }
    }
}

private extension ReadCollectionItemsViewModel {
    
    var attributeCell: Observable<[ReadCollectionAttrCellViewModel]> {
        
        let filtering: ([ReadCollectionItemSection]) -> [ReadCollectionAttrCellViewModel]
        filtering = { sections in
            return sections
                .flatMap{ $0.cellViewModels }
                .compactMap { $0  as? ReadCollectionAttrCellViewModel }
        }
        return self.sections.map(filtering)
    }
    
    var cellViewModels: Observable<[ReadItemCellViewModel]> {
        let filtering: ([ReadCollectionItemSection]) -> [ReadItemCellViewModel]
        filtering = { sections in
            return sections
                .flatMap{ $0.cellViewModels }
                .filter{ $0 is ReadCollectionCellViewModel || $0 is ReadLinkCellViewModel }
        }
        return self.sections.map(filtering)
    }
}


private extension ReadPriority {
    
    static func makeDummy(_ seqIndex: Int) -> ReadPriority? {
        switch seqIndex {
        case 1: return .beforeDying
        case 2: return .someDay
        case 3: return .thisWeek
        case 4: return .today
        case 5: return .beforeGoToBed
        case 6: return .onTheWaytoWork
        case 7: return .afterAWhile
        default: return nil
        }
    }
}

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
import UsecaseDoubles
import UnitTestHelpKit

@testable import ReadItemScene


class ReadCollectionViewModelTests: BaseTestCase,  WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: FakeRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private var dummySubCollections: [ReadCollection] {
        return (0..<5).map { int -> ReadCollection in
            return ReadCollection.dummy(int)
                |> \.priority .~ ReadPriority(rawValue: int)
        }
    }
    
    private var dummySubLinks: [ReadLink] {
        return (5..<10).map { int -> ReadLink in
            return ReadLink.dummy(int)
                |> \.priority .~ ReadPriority(rawValue: int)
        }
    }
    
    private var dummyCollectionItems: [ReadItem] {
        return self.dummySubCollections + self.dummySubLinks
    }
    
    func makeViewModel(isRootCollection: Bool = false,
                       shouldFailReload: Bool = false,
                       sortOrder: ReadCollectionItemSortOrder = .default) -> ReadCollectionViewModelImple {
        let reloadResult: Result<[ReadItem], Error> = shouldFailReload
            ? .failure(ApplicationErrors.invalid)
            : .success(self.dummyCollectionItems)
        let scenario = StubReadItemUsecase.Scenario()
            |> \.collectionItems .~ reloadResult
            |> \.sortOrder .~ .success(sortOrder)
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        let router = FakeRouter()
        self.spyRouter = router
        
        let collectionID = isRootCollection ? ReadCollection.rootID : "some"
        return .init(collectionID: collectionID,
                     readItemUsecase: stubUsecase,
                     router: router)
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
    
    // toggle mode
    func testViewModel_toggleItemShrinkStyle() {
        // given
        let expect = expectation(description: "아이템 간략히보기 여부 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollectionItems()
            viewModel.toggleShrinkListStyle()
            viewModel.toggleShrinkListStyle()
        }
        
        // then
        let shrinkItemCounts = cvmLists.map {
            return $0.filter { $0.isShrink }.count
        }
        XCTAssertEqual(shrinkItemCounts, [0, 10, 0])
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
}

// TODO: - change order + update custom order

extension ReadCollectionViewModelTests {
    
    
}

// MAARK: - provide thumbnail

extension ReadCollectionViewModelTests {
    
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
        return ReadCollection(uid: "new-collection", name: "new collection", createdAt: .now(), lastUpdated: .now())
    }
    
    private var newLinkItem: ReadLink {
        return ReadLink(uid: "new-link", link: "new link", createAt: .now(), lastUpdated: .now())
    }
    
    func testViewModel_whenAfterMakeNewCollection_appendItemAndReload() {
        // given
        let expect = expectation(description: "콜렉션 생성이후 아이템 추가해서 리로드")
        let viewModel = self.makeViewModel(sortOrder: .byCreatedAt(false))
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels.withoutAttrCell(), skip: 1) {
            viewModel.reloadCollectionItems()
            
            self.spyRouter.mockNewCollection = self.newCollection
            viewModel.requestMakeNewCollection()
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
            viewModel.requestAddNewLink()
        }
        
        // then
        let linkCells = cvms?.compactMap{ $0 as? ReadLinkCellViewModel }
        XCTAssertEqual(cvms?.count, self.dummyCollectionItems.count + 1)
        XCTAssertEqual(linkCells?.first?.uid, self.newLinkItem.uid)
    }
}

extension ReadCollectionViewModelTests {
    
    class FakeRouter: ReadCollectionRouting, Mocking {
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
        
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
        
        func showLinkDetail(_ linkID: String) {
            self.verify(key: "showLinkDetail")
        }
        
        var mockNewCollection: ReadCollection?
        func routeToMakeNewCollectionScene(_ completedHandler: @escaping (ReadCollection) -> Void) {
            guard let mock = self.mockNewCollection else { return }
            completedHandler(mock)
        }
        
        var mockNewLink: ReadLink?
        func routeToAddNewLink(at collectionID: String, _ completionHandler: @escaping (ReadLink) -> Void) {
            guard let mock = self.mockNewLink else { return }
            completionHandler(mock)
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

private extension ReadCollectionViewModel {
    
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

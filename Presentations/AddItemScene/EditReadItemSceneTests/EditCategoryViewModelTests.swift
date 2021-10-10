//
//  EditCategoryViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/10.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class EditCategoryViewModelTests: BaseTestCase, WaitObservableEvents, EditCategoryRouting, EditCategorySceneListenable {
    
    var disposeBag: DisposeBag!
    var didAlertError: (() -> Void)?
    var didClose: Bool?
    var didSelectedCategories: (([ItemCategory]) -> Void)?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didAlertError = nil
        self.didSelectedCategories = nil
        self.didClose = nil
    }
    
    func alertError(_ error: Error) {
        self.didAlertError?()
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    func editCategory(didSelect categories: [ItemCategory]) {
        self.didSelectedCategories?(categories)
    }
    
    private var dummyLatests: [SuggestCategory] {
        return (100..<102).map { .dummy($0) }
    }
    
    private var suggestResult1: [SuggestCategoryCollection] {
        return (0..<3).map { index in
            return .dummy("q1", page: index, nextCursor: index != 2 ? "some" : nil)
        }
    }
    
    private var suggestResult2: [SuggestCategoryCollection] {
        return []
    }
    
    private func makeViewModel(startWith: [ItemCategory] = [],
                               shouldFailMakeNewCategory: Bool = false) -> EditCategoryViewModel {
        
        let scenario = StubSuggestCategoryUsecase.Scenario()
            |> \.latestCategories .~ self.dummyLatests
            |> \.suggestResultMap .~ ["q1": self.suggestResult1, "q2": self.suggestResult2]
        let stubUsecase = StubSuggestCategoryUsecase(scenario: scenario)
        
        let cateScenario = StubItemCategoryUsecase.Scenario()
            |> \.updateResult .~ (shouldFailMakeNewCategory ? .failure(ApplicationErrors.invalid) : .success(()))
        let stubCateUsecase = StubItemCategoryUsecase(scenario: cateScenario)
        
        return EditCategoryViewModelImple(startWith: startWith,
                                          categoryUsecase: stubCateUsecase,
                                          suggestUsecase: stubUsecase,
                                          router: self, listener: self)
    }
}


extension EditCategoryViewModelTests {
    
    typealias CVM = SuggestingCategoryCellViewModel
    
    // prepare -> show latests categories
    func testViewModel_showLatestCategories() {
        // given
        let expect = expectation(description: "최초에 최근 사용한 카테고리 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewMdoels = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
        }
        
        // then
        let ids = cellViewMdoels?.compactMap { $0 as? CVM }.map { $0.uid }
        XCTAssertEqual(ids, self.dummyLatests.map { $0.category.uid } )
    }
    
    // enter name -> find matching -> show
    func testViewModel_suggestMatchingItems() {
        // given
        let expect = expectation(description: "텍스트 입력 이후에 매칭되는 결과 반환")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let cvmStreams = self.waitElements(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
            viewModel.suggest("q1")
        }
        
        // then
        let idsLists = cvmStreams.map { $0.compactMap { $0 as? CVM }.map { $0.uid} }
        XCTAssertEqual(idsLists, [
            self.dummyLatests.map { $0.category.uid },
            self.suggestResult1.first?.categories.map { $0.category.uid }
        ])
    }
    
    // enter name -> after find matching -> paging
    func testViewModel_suggestMatchingItems_andPaging() {
        // given
        let expect = expectation(description: "텍스트 입력 이후에 매칭되는 결과 반환 => 이후 페이징")
        expect.expectedFulfillmentCount = 4
        let viewModel = self.makeViewModel()
        
        // when
        let cvmStreams = self.waitElements(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
            viewModel.suggest("q1")
            viewModel.loadMore()
            viewModel.loadMore()
            viewModel.loadMore() // no result
        }
        
        // then
        let idsLists = cvmStreams.map { $0.compactMap { $0 as? CVM }.map { $0.uid} }
        XCTAssertEqual(idsLists, [
            self.dummyLatests.map { $0.category.uid },
            self.suggestResult1[safe: 0]?.categories.map { $0.category.uid },
            self.suggestResult1[safe: 1]?.categories.map { $0.category.uid },
            self.suggestResult1[safe: 2]?.categories.map { $0.category.uid },
        ])
    }
    
    // show search list -> clear text -> show default list
    func testViewModel_whenClearInputAfterSuggestSomething_showDefaultList() {
        // given
        let expect = expectation(description: "서제스트 이후 인풋 클리어시에 디폴트리스트(최근 목록) 노출")
        expect.expectedFulfillmentCount = 4
        let viewModel = self.makeViewModel()
        
        // when
        let cvmStreams = self.waitElements(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
            viewModel.suggest("q1")
            viewModel.suggest("")
            viewModel.suggest("q2")
        }
        
        // then
        let idsLists = cvmStreams.map { $0.compactMap { $0 as? CVM }.map { $0.uid} }
        XCTAssertEqual(idsLists, [
            self.dummyLatests.map { $0.category.uid },
            self.suggestResult1[safe: 0]?.categories.map { $0.category.uid },
            self.dummyLatests.map { $0.category.uid },
            [],
        ])
    }
}


extension EditCategoryViewModelTests {
    
    // select item -> update selected cell
    func testViewModel_whenAfterSelectCell_updateSelectedCells() {
        // given
        let expect = expectation(description: "카테고리 선택시에 선택된 셀 목록 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let selectCVMs = self.waitElements(expect, for: viewModel.selectedCellViewModels) {
            viewModel.prepareCategoryList()
            viewModel.select("c:100")
        }
        
        // then
        let ids = selectCVMs.map { $0.map { $0.uid } }
        XCTAssertEqual(ids, [
            [], ["c:100"]
        ])
    }
    
    func testViewModel_whenStartWithSelectionExists_show() {
        // given
        let expect = expectation(description: "이미 선택된 항목이 있는경우 선택목록 최초에 노출")
        let viewModel = self.makeViewModel(startWith: [.dummy(100)])
        
        // when
        let selectCVMs = self.waitFirstElement(expect, for: viewModel.selectedCellViewModels) {
            viewModel.prepareCategoryList()
        }
        
        // then
        let ids = selectCVMs.map { $0.map { $0.uid } }
        XCTAssertEqual(ids, ["c:100"])
    }
    
    // select item -> update list(exclude)
    func testViewModel_whenAfterSelectItem_hideFromList() {
        // given
        let expect = expectation(description: "아이템 선택 이후에 서제스트 리스트에서는 숨김")
        expect.expectedFulfillmentCount = 5
        let viewModel = self.makeViewModel()
        
        // when
        let cvmStreams = self.waitElements(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
            viewModel.select("c:100")
            viewModel.suggest("q1")
            viewModel.select("c:1")
        }
        
        // then
        let idsLists = cvmStreams.map { $0.compactMap { $0 as? CVM }.map { $0.uid} }
        XCTAssertEqual(idsLists.count, 5)
        XCTAssertEqual(idsLists[safe: 0]?.contains("c:100"), true)
        XCTAssertEqual(idsLists[safe: 1]?.contains("c:100"), false)
        XCTAssertEqual(idsLists[safe: 2]?.contains("c:1"), true)
        XCTAssertEqual(idsLists[safe: 3]?.contains("c:1"), false)
        XCTAssertEqual(idsLists[safe: 4]?.contains("c:100"), false) // 선택 완료시에 목록 초기화되고 디폴트 리스트 노출
    }
    
    // deselect item -> update remove from selected cell
    func testViewModel_diselect() {
        // given
        let expect = expectation(description: "선택 취소시 선택 리스트에서 삭제")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let selectCVMs = self.waitElements(expect, for: viewModel.selectedCellViewModels) {
            viewModel.prepareCategoryList()
            viewModel.select("c:100")
            viewModel.deselect("c:100")
        }
        
        // then
        let ids = selectCVMs.map { $0.map { $0.uid } }
        XCTAssertEqual(ids, [
            [], ["c:100"], []
        ])
    }
    
    // deselect item -> appear from list
    func testViewModel_whenAfterDeseelct_reapeparAtSuggestList() {
        // given
        let expect = expectation(description: "선택해제 이후에 서제스트 목록에 다시 노출")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let cvmStreams = self.waitElements(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
            viewModel.select("c:100")
            viewModel.deselect("c:100")
        }
        
        // then
        let idsLists = cvmStreams.map { $0.compactMap { $0 as? CVM }.map { $0.uid} }
        XCTAssertEqual(idsLists[safe: 0]?.contains("c:100"), true)
        XCTAssertEqual(idsLists[safe: 1]?.contains("c:100"), false)
        XCTAssertEqual(idsLists[safe: 2]?.contains("c:100"), true)
    }
}


extension EditCategoryViewModelTests {
    
    // make category
    func testViewModel_whenSuggestResultIsEmpty_showMakeCell() {
        // given
        let expect = expectation(description: "검색결과 없을때는 카테고리 생성 셀 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 2) {
            viewModel.prepareCategoryList()
            viewModel.suggest("q2")
        }
        
        // then
        let makeCells = cvms?.compactMap { $0 as? SuggestMakeNewCategoryCellViewMdoel }
        XCTAssertEqual(makeCells?.count, 1)
        XCTAssertEqual(makeCells?.first?.name, "q2")
    }
    
    // after make category -> append selected item
    func testViewModel_whenAfterMakeNewCategory_appendSelectedCell() {
        // given
        let expect = expectation(description: "카테고리 생성 이후에 선택된 셀에 추가")
        let viewModel = self.makeViewModel()
        
        // when
        let selectCVMs = self.waitFirstElement(expect, for: viewModel.selectedCellViewModels, skip: 1) {
            viewModel.prepareCategoryList()
            viewModel.suggest("q2")
            viewModel.makeNew(.init("q2", "some"))
        }
        
        // then
        XCTAssertEqual(selectCVMs?.count, 1)
        XCTAssertEqual(selectCVMs?.first?.name, "q2")
    }
    
    func testViewModel_whenAfterMakeNewCategory_notShowAtSuggestList() {
        // given
        let expect = expectation(description: "카테고리 생성 이후에 디폴트 서제스트 목록 노출")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewModels = self.waitElements(expect, for: viewModel.cellViewModels, skip: 2) {
            viewModel.prepareCategoryList()
            viewModel.suggest("q2")
            viewModel.makeNew(.init("q2", "some"))
        }
        
        // then
        let cvmsFirst = cellViewModels.first
        let cvmLast = cellViewModels.last
        XCTAssert(cvmsFirst?.first is SuggestMakeNewCategoryCellViewMdoel)
        XCTAssertEqual(cvmsFirst?.count, 1)
        XCTAssertEqual(cvmLast?.count, 2)
    }
    
    // make category error -> show errorr
    func testViewModel_whenMakeNewCategoryError_alert() {
        // given
        let expect = expectation(description: "카테고리 생성 실패시에 에러 알림")
        let viewModel = self.makeViewModel(shouldFailMakeNewCategory: true)
        
        self.didAlertError = {
            expect.fulfill()
        }
        // when
        viewModel.prepareCategoryList()
        viewModel.suggest("q2")
        viewModel.makeNew(.init("q2", "some"))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // TODO: request change category color
    
    // TODO: after color changed update
}


extension EditCategoryViewModelTests {
    
    // confirm select -> close and emit event
    func testViewModel_whenAfterSelectCategory_closeAndEmitEvent() {
        // given
        let expect = expectation(description: "카테고리 선택 이후에 화면 닫고 외부로 이벤트 전파")
        let viewModel = self.makeViewModel()
        
        var selectedCategories: [ItemCategory]?
        self.didSelectedCategories = {
            selectedCategories = $0
            expect.fulfill()
        }

        // when
        viewModel.prepareCategoryList()
        viewModel.select("c:100")
        viewModel.suggest("q1")
        viewModel.select("c:1")
        viewModel.suggest("q2")
        viewModel.makeNew(.init("q2", "some"))
        viewModel.confirmSelect()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(selectedCategories?[safe: 0]?.uid, "c:100")
        XCTAssertEqual(selectedCategories?[safe: 1]?.uid, "c:1")
        XCTAssertEqual(selectedCategories?[safe: 2]?.name, "q2")
    }
}

//
//  ManageCategoryViewModelTests.swift
//  SettingSceneTests
//
//  Created by sudo.park on 2021/12/03.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import SettingScene


class ManageCategoryViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
    }
    
    var dummyCategoies: [[ItemCategory]] {
        return [
            (0..<30).map { ItemCategory.dummy($0) },
            (30..<60).map { ItemCategory.dummy($0) },
            (60..<64).map { ItemCategory.dummy($0) }
        ]
    }
    
    private func makeViewModel() -> ManageCategoryViewModel {
        let router = SpyRouter()
        self.spyRouter = router
        
        let scnenario = StubItemCategoryUsecase.Scenario()
            |> \.categoriesWithPaging .~ self.dummyCategoies
        let usecase = StubItemCategoryUsecase(scenario: scnenario)
        return ManageCategoryViewModelImple(categoryUsecase: usecase, router: router, listener: nil)
    }
}


extension ManageCategoryViewModelTests {
    
    // show pages until end
    func testViewModel_loadCategories_untilEnd() {
        // given
        let expect = expectation(description: "마지막까지 카테고리 로드")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.refresh()     // 0~30
            viewModel.loadMore()    // 30~60
            viewModel.loadMore()    // 60~64
            viewModel.loadMore()    // empty => not changed
            viewModel.loadMore()    // not load
        }
        
        // then
        let idLists = cvmLists.map { $0.map { $0.uid } }
        XCTAssertEqual(idLists, [
            (0..<30).map { "c:\($0)" },
            (0..<60).map { "c:\($0)" },
            (0..<64).map { "c:\($0)" }
        ])
    }
    
    func testViewModel_requestModify() {
        // given
        let expect = expectation(description: "카테고리 수정 요청")
        let viewModel = self.makeViewModel()
        
        
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.refresh()
        }
        
        // when
        let target = cvms?.randomElement()
        viewModel.editCategory(target?.uid ?? "")
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToEditCategory, true)
    }
    
    func testViewModel_removeCategoryWithConfirm() {
        // given
        let expect = expectation(description: "삭제 확인과 함께 카테고리 삭제")
        let viewModel = self.makeViewModel()
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels, skip: 1) {
            viewModel.refresh()
            viewModel.removeCategory("c:2")
        }
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertConfirmed, true)
        XCTAssertEqual(cvms?.count, 29)
        XCTAssertEqual(cvms?.contains(where: { $0.uid == "c:2" } ), false)
    }
}


extension ManageCategoryViewModelTests {
    
    class SpyRouter: ManageCategoryRouting {

        var didMoveToEditCategory: Bool?
        func moveToEditCategory(_ category: ItemCategory) {
            self.didMoveToEditCategory = true
        }
        
        var didAlertConfirmed: Bool?
        func alertForConfirm(_ form: AlertForm) {
            self.didAlertConfirmed = true
            form.confirmed?()
        }
    }
}

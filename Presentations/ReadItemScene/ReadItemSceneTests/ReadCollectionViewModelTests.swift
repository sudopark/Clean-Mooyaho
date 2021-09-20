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

import ReadItemScene


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
                       shouldFailReload: Bool = false) -> ReadCollectionViewModelImple {
        let reloadResult: Result<[ReadItem], Error> = shouldFailReload
            ? .failure(ApplicationErrors.invalid)
            : .success(self.dummyCollectionItems)
        let scenario = StubReadItemUsecase.Scenario()
            |> \.collectionItems .~ reloadResult
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        let router = FakeRouter()
        self.spyRouter = router
        
        let collectionID = isRootCollection ? nil : "some"
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
        XCTAssertEqual(cvms?.count, 10)
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
    
//    func testViewModel_showCurrentOrder() {
//        // given
//        let expect = expectation(description: "현재 정렬옵션 노출")
//        
//        // when
//        // then
//    }
}

// MAARK: - change order + update custom order

extension ReadCollectionViewModelTests {
    
}

// MAARK: - provide thumbnail

extension ReadCollectionViewModelTests {
    
}

// MAARK: - show detail

extension ReadCollectionViewModelTests {
    
}

extension ReadCollectionViewModelTests {
    
    class FakeRouter: ReadCollectionRouting, Mocking {
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
    }
}

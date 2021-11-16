//
//  SharedCollectionItemsViewModelTests.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/17.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UsecaseDoubles
import UnitTestHelpKit

@testable import DiscoveryScene


class SharedCollectionItemsViewModelTests: BaseTestCase, WaitObservableEvents {
    
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func makeViewModel() -> SharedCollectionItemsViewModel {
        
        let shareUsecase = StubShareItemUsecase()
        let itemsUsecase = StubReadItemUsecase()
        let categoryUsecase = StubItemCategoryUsecase()
        
        return SharedCollectionItemsViewModelImple(currentCollection: .dummy(0),
                                                   loadSharedCollectionUsecase: shareUsecase,
                                                   linkPreviewLoadUsecase: itemsUsecase,
                                                   readItemOptionsUsecase: itemsUsecase,
                                                   categoryUsecase: categoryUsecase,
                                                   router: DummyRouter(),
                                                   listener: nil,
                                                   navigationListener: DummyListener())
    }
}


extension SharedCollectionItemsViewModelTests {
    
    func testViewModel_showSubCollectionItems() {
        // given
        let expect = expectation(description: "서브아이템 로드")
        let viewModel = self.makeViewModel()
        
        // when
        let source = viewModel.sections.skip(while: { $0.isEmpty })
        let sections = self.waitFirstElement(expect, for: source) {
            viewModel.reloadCollectionSubItems()
        }
        
        // then
        XCTAssertEqual(sections?.isNotEmpty, true)
    }
}


extension SharedCollectionItemsViewModelTests {
    
    class DummyRouter: SharedCollectionItemsRouting {
        
        func moveToSubCollection(collection: SharedReadCollection) { }
        
        func showLinkDetail(_ link: SharedReadLink) { }
    }
    
    class DummyListener: ReadCollectionNavigateListenable {
        
    }
}

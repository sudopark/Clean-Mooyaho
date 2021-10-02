//
//  ReadCollectionMainViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/10/02.
//

import XCTest

import Domain
import UnitTestHelpKit

import ReadItemScene


class ReadCollectionMainViewModelTests: BaseTestCase {
    
    private var spyRouter: SpyRouter!
    
    override func tearDownWithError() throws {
        self.spyRouter = nil
    }
    
    private func makeViewModel() -> ReadCollectionMainViewModel {
        
        let router = SpyRouter()
        self.spyRouter = router
        return ReadCollectionMainViewModelImple(router: router)
    }
}


extension ReadCollectionMainViewModelTests {
    
    func testViewModel_setupSubCollections() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.setupSubCollections()
        
        // then
        XCTAssertEqual(self.spyRouter.isSubCollectionSetuped, true)
    }
    
    func testViewModel_requestShowSelectAddItemType() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.showSelectAddItemTypeScene()
        
        // then
        XCTAssertEqual(self.spyRouter.isShowSelectAddItemRequested, true)
    }
}


extension ReadCollectionMainViewModelTests {
    
    
    class SpyRouter: ReadCollectionMainRouting {
        
        var isSubCollectionSetuped: Bool = false
        
        func setupSubCollections() {
            self.isSubCollectionSetuped = true
        }
        
        var isShowSelectAddItemRequested = false
        
        func showSelectAddItemTypeScene() {
            self.isShowSelectAddItemRequested = true
        }
    }
}

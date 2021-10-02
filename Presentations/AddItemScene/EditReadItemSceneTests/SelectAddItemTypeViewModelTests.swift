//
//  SelectAddItemTypeViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/10/02.
//

import XCTest

import Domain
import UnitTestHelpKit

import AddItemScene


class SelectAddItemTypeViewModelTests: BaseTestCase {
    
    var didSelectCollectionOrLink: ((Bool) -> Void)?
    
    override func tearDownWithError() throws {
        self.didSelectCollectionOrLink = nil
    }
    
    private func makeViewModel() -> SelectAddItemTypeViewModel {
        
        let selected: (Bool) -> Void = {
            self.didSelectCollectionOrLink?($0)
        }
        
        return SelectAddItemTypeViewModelImple(router: self,
                                               completed: selected)
    }
}

extension SelectAddItemTypeViewModelTests {
    
    func testViewModel_selectAddNewCollection() {
        // given
        let expect = expectation(description: "새 콜렉션 추가 화면으로 이동")
        let viewModel = self.makeViewModel()
        var isCollectionSelected: Bool?
        
        self.didSelectCollectionOrLink = {
            isCollectionSelected = $0
            expect.fulfill()
        }
        
        // when
        viewModel.requestAddNewCollection()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(isCollectionSelected, true)
    }
    
    func testViewModel_selectAddnewReadLinkItem() {
        // given
        let expect = expectation(description: "새 리드 아이템 추가 화면으로 이동")
        let viewModel = self.makeViewModel()
        var isCollectionSelected: Bool?
        
        self.didSelectCollectionOrLink = {
            isCollectionSelected = $0
            expect.fulfill()
        }
        
        // when
        viewModel.requestAddNewReadLink()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(isCollectionSelected, false)
    }
}


extension SelectAddItemTypeViewModelTests: SelectAddItemTypeRouting {
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        completed?()
    }
}

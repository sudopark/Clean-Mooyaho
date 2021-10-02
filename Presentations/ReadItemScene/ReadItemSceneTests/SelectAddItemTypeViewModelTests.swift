//
//  SelectAddItemTypeViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/10/02.
//

import XCTest

import Domain
import UnitTestHelpKit

import ReadItemScene


class SelectAddItemTypeViewModelTests: BaseTestCase {
    
    var didMoveAddNewCollection: (() -> Void)?
    var didMoveAddNewReadLinkItem: (() -> Void)?
    
    override func tearDownWithError() throws {
        self.didMoveAddNewCollection = nil
        self.didMoveAddNewReadLinkItem = nil
    }
    
    private func makeViewModel() -> SelectAddItemTypeViewModel {
        
        return SelectAddItemTypeViewModelImple(router: self)
    }
}

extension SelectAddItemTypeViewModelTests {
    
    func testViewModel_selectAddNewCollection() {
        // given
        let expect = expectation(description: "새 콜렉션 추가 화면으로 이동")
        let viewModel = self.makeViewModel()
        
        self.didMoveAddNewCollection = { expect.fulfill() }
        
        // when
        viewModel.requestAddNewCollection()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_selectAddnewReadLinkItem() {
        // given
        let expect = expectation(description: "새 리드 아이템 추가 화면으로 이동")
        let viewModel = self.makeViewModel()
        
        self.didMoveAddNewReadLinkItem = { expect.fulfill() }
        
        // when
        viewModel.requestAddNewReadLink()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension SelectAddItemTypeViewModelTests: SelectAddItemTypeRouting {
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        completed?()
    }
    
    func showAddNewCollectionScene() {
        self.didMoveAddNewCollection?()
    }
    
    func showAddNewReadLinkScene() {
        self.didMoveAddNewReadLinkItem?()
    }
}

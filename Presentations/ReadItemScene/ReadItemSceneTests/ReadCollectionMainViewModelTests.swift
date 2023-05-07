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
    
    var didSubCollectionSetuped: Bool = false
    var didMoveToAddnewCollection: Bool = false
    var didMoveToAddNewLink: Bool = false
    
    override func tearDownWithError() throws {
        self.didSubCollectionSetuped = false
        self.didMoveToAddnewCollection = false
        self.didMoveToAddNewLink = false
    }
    
    private func makeViewModel() -> ReadCollectionMainViewModel {
        return ReadCollectionMainViewModelImple(router: self, navigationListener: nil)
    }
}


extension ReadCollectionMainViewModelTests {
    
    func testViewModel_setupSubCollections() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.setupSubCollections()
        
        // then
        XCTAssertEqual(self.didSubCollectionSetuped, true)
    }
    
    func testViewModel_requestAddNewCollection() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.addNewCollectionItem()
        
        // then
        XCTAssertEqual(self.didMoveToAddnewCollection, true)
    }
    
    func testViewModel_requestAddNewReadLinkItem() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.addNewReadLinkItem()
        
        // then
        XCTAssertEqual(self.didMoveToAddNewLink, true)
    }
}


extension ReadCollectionMainViewModelTests: ReadCollectionMainRouting, @unchecked Sendable {
    
    func addNewReadLinkItem(using url: String) {
        
    }
    
    func setupSubCollections() {
        self.didSubCollectionSetuped = true
    }
    
    func addNewColelctionAtCurrentCollection() {
        self.didMoveToAddnewCollection = true
    }
    
    func addNewReadLinkItemAtCurrentCollection() {
        self.didMoveToAddNewLink = true
    }
    
    func switchToMyReadCollection() { }
    
    func switchToSharedCollection(root: SharedReadCollection) { }
    
    func jumpToCollection(_ collectionID: String) { }
    
    func moveToRootCollection() { }
}

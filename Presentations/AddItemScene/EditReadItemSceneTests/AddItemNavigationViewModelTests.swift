//
//  AddItemNavigationViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/02.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class AddItemNavigationViewModelTests: BaseTestCase, AddItemNavigationSceneListenable {
    
    private var didNavigationSetup: Bool?
    private var didMoveToEnterURLScene: Bool?
    private var didMoveToConfirmAdd: Bool?
    private var didClosed: Bool?
    private var enterURLMocking: ((String) -> Void)?
    private var didAddedItem: ReadLink?
    private var didPop: Bool?
    
    private var interactor: AddItemNavigationSceneInteractable?
    
    override func tearDownWithError() throws {
        self.didNavigationSetup = nil
        self.didMoveToEnterURLScene = nil
        self.didMoveToConfirmAdd = nil
        self.didClosed = nil
        self.enterURLMocking = nil
        self.didPop = nil
    }
    
    private func makeViewModel() -> AddItemNavigationViewModel {
        
        let viewModel = AddItemNavigationViewModelImple(startWith: nil,
                                                        targetCollectionID: nil,
                                                        router: self, listener: self)
        self.interactor = viewModel
        return viewModel
    }
    
    func addReadLink(didAdded newItem: ReadLink) {
        self.didAddedItem = newItem
    }
}

extension AddItemNavigationViewModelTests {
    
    
    func testViewModel_prepareNavigation() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        
        // then
        XCTAssertEqual(self.didNavigationSetup, true)
    }
    
    func testViewModel_whenAfterprepareNavigation_moveToEnterURLScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        
        // then
        XCTAssertEqual(self.didMoveToEnterURLScene, true)
    }
    
    func testViewMdoeL_whenAfterEnterURLEnd_moveToAddnewItemScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        self.enterURLMocking?("https://wwww.dummy_url.com")
        
        // then
        XCTAssertEqual(self.didMoveToConfirmAdd, true)
    }
    
    func testViewModel_whenAfterAddIteMConfirmCompleted_closeAndEmitNewItem() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.prepareNavigation()
        self.enterURLMocking?("https://wwww.dummy_url.com")
        
        // then
        XCTAssertEqual(self.didClosed, true)
    }
    
    func testViewModel_popToEnterURLScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.requestpopToEnrerURLScene()
        
        // then
        XCTAssertEqual(self.didPop, true)
    }
}


extension AddItemNavigationViewModelTests: AddItemNavigationRouting {
    
    func prepareNavigation() {
        self.didNavigationSetup = true
    }
    
    func pushToEnterURLScene(startWith url: String?, _ entered: @escaping (String) -> Void) {
        self.didMoveToEnterURLScene = true
        self.enterURLMocking = { entered($0) }
    }
    
    func pushConfirmAddLinkItemScene(at collectionID: String?,
                                     url: String) {
        self.didMoveToConfirmAdd = true
        self.interactor?.editReadLink(didEdit: .dummy(0))
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClosed = true
        completed?()
    }
    
    func popToEnrerURLScene() {
        self.didPop = true
    }
}

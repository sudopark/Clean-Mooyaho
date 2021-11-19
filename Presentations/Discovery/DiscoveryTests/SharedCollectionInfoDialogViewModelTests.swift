//
//  SharedCollectionInfoDialogViewModelTests.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/20.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import DiscoveryScene


class SharedCollectionInfoDialogViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyListener: SpyRouterListener!
    var spyRouter: SpyRouterListener!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func makeViewModel(shouldFailRemove: Bool = false) -> SharedCollectionInfoDialogViewModel {
        
        let routerAndListener = SpyRouterListener()
        self.spyListener = routerAndListener
        self.spyRouter = routerAndListener
        
        let scenario = StubShareItemUsecase.Scenario()
            |> \.removeResult .~ (shouldFailRemove ? .failure(ApplicationErrors.invalid) : .success(()))
        let usecase = StubShareItemUsecase(scenario: scenario)
        
        return SharedCollectionInfoDialogViewModelImple(collection: .dummy(0),
                                                        shareItemsUsecase: usecase,
                                                        router: routerAndListener,
                                                        listener: routerAndListener)
    }
}


extension SharedCollectionInfoDialogViewModelTests {
    
    func testViewModel_removeFromSharedList() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.removeFromSharedList()
        
        // then
        XCTAssertEqual(self.spyRouter.didClose, true)
        XCTAssertEqual(self.spyListener.didRemoved, true)
    }
    
    func testViewModel_whenRemoving_updateIsRemoving() {
        // given
        let expect = expectation(description: "삭제중에는 삭제중 표시")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isRemovings = self.waitElements(expect, for: viewModel.isRemoving) {
            viewModel.removeFromSharedList()
        }
        
        // then
        XCTAssertEqual(isRemovings, [false, true, false])
    }
    
    func testViewModel_whenRemoveFail_showError() {
        // given
        let viewModel = self.makeViewModel(shouldFailRemove: true)
        
        // when
        viewModel.removeFromSharedList()
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertError, true)
    }
}


extension SharedCollectionInfoDialogViewModelTests {
    
    class SpyRouterListener: SharedCollectionInfoDialogRouting, SharedCollectionInfoDialogSceneListenable {
        
        var didAlertError = false
        func alertError(_ error: Error) {
            self.didAlertError = true
        }
        
        var didClose = false
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.didClose = true
            completed?()
        }
        
        var didRemoved: Bool = false
        func sharedCollectionDidRemoved(_ sharedID: String) {
            self.didRemoved = true
        }
        
        func alertForConfirm(_ form: AlertForm) {
            form.confirmed?()
        }
    }
}

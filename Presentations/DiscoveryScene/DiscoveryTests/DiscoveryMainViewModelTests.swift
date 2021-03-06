//
//  DiscoveryMainViewModelTests.swift
//  DiscoverySceneTests
//
//  Created by sudo.park on 2021/11/15.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import DiscoveryScene


class DiscoveryMainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: SpyRouterAndListener!
    private var spyListener: SpyRouterAndListener!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.spyListener = nil
    }
    
    private var dummyCollections: [SharedReadCollection] {
        return (0..<10).map {
            return SharedReadCollection.dummy($0)
                |> \.ownerID .~ "oid:\($0)"
        }
    }
    
    private func makeViewModel(currentCollectionShareID: String? = nil,
                               isEmptyList: Bool = false,
                               isSignIn: Bool = true) -> DiscoveryMainViewModel {
        
        let dummies = self.dummyCollections
        let scenario = StubShareItemUsecase.Scenario()
            |> \.latestCollections .~ (isEmptyList ? [] :  [dummies])
        let usecase = StubShareItemUsecase(scenario: scenario)
        
        let owners = dummyCollections.compactMap { $0.ownerID }
            .map { Member(uid: $0, nickName: "some", icon: nil) }
        let memberScenario = BaseStubMemberUsecase.Scenario()
            |> \.members .~ .success(owners)
            |> \.currentMember .~ (isSignIn ? Member(uid: "some", nickName: nil, icon: nil) : nil)
        let memberUsecase = BaseStubMemberUsecase(scenario: memberScenario)
        
        let routerAndListener = SpyRouterAndListener()
        self.spyRouter = routerAndListener
        self.spyListener = routerAndListener
        
        return DiscoveryMainViewModelImple(currentSharedCollectionShareID: currentCollectionShareID,
                                           sharedReadCollectionLoadUsecase: usecase,
                                           memberUsecase: memberUsecase,
                                           router: self.spyRouter,
                                           listener: self.spyListener)
    }
}


extension DiscoveryMainViewModelTests {
    
    func testViewModel_showLatestShareCollections() {
        // given
        let expect = expectation(description: "?????? ???????????? ????????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let source = viewModel.cellViewModels.skip(while: { $0.isEmpty } )
        let cvms = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(cvms?.count, 10)
    }
    
    func testViewModel_markCurrentCollection() {
        // given
        let expect = expectation(description: "?????? ???????????? ????????????")
        let currentShareID = self.dummyCollections.randomElement()?.shareID
        let viewModel = self.makeViewModel(currentCollectionShareID: currentShareID)
        
        // when
        let source = viewModel.cellViewModels.skip(while: { $0.isEmpty } )
        let cvms = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        let markedCells = cvms?.filter { $0.isCurrentCollection == true }
        XCTAssertEqual(markedCells?.count, 1)
        XCTAssertEqual(markedCells?.first?.shareID, currentShareID)
    }
    
    func testViewModel_provideOwnerInfo() {
        // given
        let expect = expectation(description: "owner ?????? ??????")
        let viewModel = self.makeViewModel()
        
        // when
        let ownerID = self.dummyCollections.randomElement()?.ownerID ?? ""
        let source = viewModel.shareOwner(for: ownerID)
        let member = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }

        // then
        XCTAssertNotNil(member)
    }
    
    func testViewModel_hasSomeList() {
        // given
        let expect = expectation(description: "??????????????? ???????????? ?????? ??????")
        let viewModel = self.makeViewModel(isEmptyList: false, isSignIn: true)
        
        // when
        let isEmpty = self.waitFirstElement(expect, for: viewModel.sharedListIsEmpty, skip: 1) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isEmpty, .notEmpty)
    }
    
    func testViewModel_whenSharedListIsEmpty_showEmpty() {
        // given
        let expect = expectation(description: "??????????????? ????????? ??????????????? ??????")
        let viewModel = self.makeViewModel(isEmptyList: true, isSignIn: true)
        
        // when
        let isEmpty = self.waitFirstElement(expect, for: viewModel.sharedListIsEmpty) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isEmpty, .empty(signInNeed: false))
    }
    
    func testViewModel_whenNotSignIn_showEmptyWithSignInNeed() {
        // given
        let expect = expectation(description: "????????? ????????????????????? ??????????????? ?????? ????????? ?????? ??????")
        let viewModel = self.makeViewModel(isSignIn: false)
        
        // when
        let isEmpty = self.waitFirstElement(expect, for: viewModel.sharedListIsEmpty) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isEmpty, .empty(signInNeed: true))
    }
    
    func testViewModel_whenSignOut_viewAllIsNotEnable() {
        // given
        let expect = expectation(description: "????????? ??????????????? ?????????????????? ???????????? ????????????")
        let viewModel = self.makeViewModel(isSignIn: false)
        
        // when
        let isEnable = self.waitFirstElement(expect, for: viewModel.viewAllSharedListEnable) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isEnable, false)
    }
    
    func testViewModel_whenSignInButItemIsEmpty_viewAllIsNotEnable() {
        // given
        let expect = expectation(description: "????????? ???????????? ????????????????????? ?????????????????? ???????????? ????????????")
        let viewModel = self.makeViewModel(isEmptyList: true, isSignIn: true)
        
        // when
        let isEnable = self.waitFirstElement(expect, for: viewModel.viewAllSharedListEnable) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isEnable, false)
    }
    
    func testViewModel_whenSignInAndItemIsNotEmpty_viewAllIsEnable() {
        // given
        let expect = expectation(description: "????????? ????????? ????????????????????? ????????? ???????????? ?????????")
        let viewModel = self.makeViewModel(isEmptyList: false, isSignIn: true)
        
        // when
        let isEnable = self.waitFirstElement(expect, for: viewModel.viewAllSharedListEnable, skip: 1) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isEnable, true)
    }
}


extension DiscoveryMainViewModelTests {
    
    func testViewModel_requestSwitchToSemeSharedCollection() {
        // given
        let expect = expectation(description: "shared colelction?????? ??????")
        let viewModel = self.makeViewModel()
        
        let source = viewModel.cellViewModels.skip(while: { $0.isEmpty } )
        let cvms = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // when
        let shareID = cvms?.randomElement()?.shareID ?? ""
        viewModel.selectCollection(shareID)
        
        // then
        XCTAssertEqual(self.spyRouter.didRequestedSwitchToSharedCollection?.shareID, shareID)
        XCTAssertEqual(self.spyListener.didSwitchRequestedAlerted, true)
    }
    
    func testViewModel_requestSwitchToMyCollection() {
        // given
        let viewModel = self.makeViewModel(currentCollectionShareID: self.dummyCollections.randomElement()?.shareID)
        
        // when
        viewModel.switchToMyCollection()
        
        // then
        XCTAssertEqual(viewModel.showSwitchToMyCollection, true)
        XCTAssertEqual(self.spyRouter.didRequestedSwitchToMyCollection, true)
        XCTAssertEqual(self.spyListener.didSwitchRequestedAlerted, true)
    }
    
    func testViewModel_requestViewAllSharedCollection() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.viewAllSharedCollections()
        
        // then
        XCTAssertEqual(self.spyRouter.didRequestViewAllSharedCollections, true)
    }
}


extension DiscoveryMainViewModelTests {
    
    class SpyRouterAndListener: DiscoveryMainRouting, DiscoveryMainSceneListenable {
        
        var didRequestedSwitchToMyCollection: Bool = false
        func routeToMyReadCollection() {
            self.didRequestedSwitchToMyCollection = true
        }
        
        var didRequestedSwitchToSharedCollection: SharedReadCollection?
        func routeToSharedCollection(_ collection: SharedReadCollection) {
            self.didRequestedSwitchToSharedCollection = collection
        }
        
        var didRequestViewAllSharedCollections = false
        func viewAllSharedCollections() {
            self.didRequestViewAllSharedCollections = true
        }
        
        var didSwitchRequestedAlerted = false
        func switchCollectionRequested() {
            self.didSwitchRequestedAlerted = true
        }
    }
}

//
//  NavigateCollectionViewModelTests.swift
//  ReadItemSceneTests
//
//  Created by sudo.park on 2021/10/26.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles


@testable import ReadItemScene


class NavigateCollectionViewModelTests: BaseTestCase, WaitObservableEvents, NavigateCollectionRouting, NavigateCollectionSceneListenable {
    
    var disposeBag: DisposeBag!
    var didMoveTo: ReadCollection?
    var didSelectCollection: ReadCollection?
    var didShowToast: Bool?
    
    var spyCoordinator: SpyInverseNavigationCoordinator!
    
    func moveToSubCollection(_ collection: ReadCollection,
                             with unSelectableCollectionID: String?,
                             listener: NavigateCollectionSceneListenable?) {
        self.didMoveTo = collection
    }
    
    func navigateCollection(didSelectCollection collection: ReadCollection?) {
        self.didSelectCollection = collection
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        completed?()
    }
    
    func showToast(_ message: String) {
        self.didShowToast = true
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.spyCoordinator = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didMoveTo = nil
        self.spyCoordinator = nil
    }
    
    var dummyCollectionItems: [ReadCollection] {
        return (1...10).map { ReadCollection.dummy($0) }
    }
    
    private var myCollectionItems: [ReadCollection] {
        return (30..<40).map { ReadCollection.dummy($0) }
    }
    
    private var dummyLinkItems: [ReadLink] {
        return (100..<110).map { ReadLink.dummy($0) }
    }
    
    private func makeViewModel(isRoot: Bool = true,
                               unselectableCollectionID: String? = nil) -> NavigateCollectionViewModel {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.myItems .~ .success(self.myCollectionItems + dummyLinkItems)
            |> \.collectionItems .~ .success(self.dummyCollectionItems + dummyLinkItems)
        let usecase = StubReadItemUsecase(scenario: scenario)
        let collection: ReadCollection? = (isRoot ? nil : ReadCollection.dummy(0))
            .map { $0 |> \.parentID .~ (isRoot ? nil : "parent") }
        return NavigateCollectionViewModelImple(currentCollection: collection,
                                                unselectableCollectionID: unselectableCollectionID,
                                                readItemUsecase: usecase,
                                                router: self,
                                                listener: self,
                                                coordinator: self.spyCoordinator)
    }
}


extension NavigateCollectionViewModelTests {
    
    func testViewModel_whenRootCollection_loadCollectionItems() {
        // given
        let expect = expectation(description: "루트콜렉션일때 루트콜렉션의 하위 콜렉션만 노출")
        let viewModel = self.makeViewModel(isRoot: true)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        }
        
        // then
        let cellIDs = cvms?.map { $0.uid }
        XCTAssertEqual(cellIDs, self.myCollectionItems.map { $0.uid })
    }
    
    func testViewModel_whenRootCollection_provideTitle() {
        // given
        let expect = expectation(description: "루트 콜렉션일때의 타이틀")
        let viewModel = self.makeViewModel(isRoot: true)
        
        // when
        let title = self.waitFirstElement(expect, for: viewModel.collectionTitle) {
            viewModel.reloadCollections()
        }
        
        // then
        XCTAssertEqual(title, "My Read Collections".localized)
    }
}


extension NavigateCollectionViewModelTests {
    
    func testViewModel_whenNotRootCollection_loadCollectionItems() {
        // given
        let expect = expectation(description: "루트콜렉션이 아닐때 하위 콜렉션만 노출")
        let viewModel = self.makeViewModel(isRoot: false)
        
        // when
        let cvms = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        }
        
        // then
        let cellIDs = cvms?.map { $0.uid }
        XCTAssertEqual(cellIDs, self.dummyCollectionItems.map { $0.uid })
    }
    
    func testViewModel_whenNotRootCollection_provideTitle() {
        // given
        let expect = expectation(description: "루트 콜렉션이 아닐때의 타이틀")
        let viewModel = self.makeViewModel(isRoot: false)
        
        // when
        let title = self.waitFirstElement(expect, for: viewModel.collectionTitle) {
            viewModel.reloadCollections()
        }
        
        // then
        XCTAssertEqual(title, "collection:0")
    }
}


extension NavigateCollectionViewModelTests {
    
    func testViewModel_markUnselectableCollection() {
        // given
        let expect = expectation(description: "선택 불가능한 콜렉션 표시")
        let dummyCollection = self.dummyCollectionItems.randomElement()!
        let viewModel = self.makeViewModel(isRoot: false, unselectableCollectionID: dummyCollection.uid)
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        } ?? []
        
        // then
        let selectableCells = cellViewModels.filter { $0.isSelectable == true }
        let nonSelectableCells = cellViewModels.filter { $0.isSelectable == false }
        XCTAssertEqual(selectableCells.count, self.dummyCollectionItems.count - 1)
        XCTAssertEqual(nonSelectableCells.count, 1)
        XCTAssertEqual(nonSelectableCells.first?.uid, dummyCollection.uid)
    }
    
    func testViewMdoel_moveToSubCollection() {
        // given
        let expect = expectation(description: "서브콜렉션으로 이동")
        let viewModel = self.makeViewModel()
        
        let _ = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        }
        
        // when
        viewModel.moveToSubCollection("c:31")
        
        // then
        XCTAssertEqual(self.didMoveTo?.uid, "c:31")
    }
    
    func testViewModel_selectCollection() {
        // given
        let expect = expectation(description: "현재 콜렉션 선택 이동")
        let viewModel = self.makeViewModel(isRoot: false)
        
        let _ = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        }
        
        // when
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didSelectCollection?.uid, "c:0")
    }
    
    func testViewModel_whenSelectNotSelectableCollection_showToast() {
        // given
        let expect = expectation(description: "선택 불가능한 콜렉션 선택시 토스트 노출")
        let dummyCollection = self.dummyCollectionItems.randomElement()!
        let viewModel = self.makeViewModel(isRoot: false, unselectableCollectionID: dummyCollection.uid)
        
        // when
        let _ = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.reloadCollections()
        }
        viewModel.moveToSubCollection(dummyCollection.uid)
        
        // then
        XCTAssertEqual(self.didMoveTo?.uid, nil)
        XCTAssertEqual(self.didShowToast, true)
    }
}


// MARK: - test prepare parent

extension NavigateCollectionViewModelTests {
    
    func testViewModel_requestPrepareParent_ifParentExists() {
        // given
        let viewModel = self.makeViewModel(isRoot: false)
        
        // when
        viewModel.requestPrepareParentIfNeed()
        
        // then
        XCTAssertNotNil(self.spyCoordinator.didRequestedPrepareParentParams)
    }
    
    func testViewModel_doNotRequestPrepareParent_ifParentNotExists() {
        // given
        let viewModel = self.makeViewModel(isRoot: true)
        
        // when
        viewModel.requestPrepareParentIfNeed()
        
        // then
        XCTAssertNil(self.spyCoordinator.didRequestedPrepareParentParams)
    }
}


class NavigateAndChageItemParentViewModelImpleTests: NavigateCollectionViewModelTests {
    
    private func targetItem(_ parentID: String?) -> ReadLink {
        return ReadLink.dummy(0)
            |> \.parentID .~ parentID
    }
    
    private var didClose: Bool?
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        self.didClose = nil
    }
    
    private func makeViewModel(isRoot: Bool, target: ReadLink) -> NavigateAndChageItemParentViewModelImple {
        let collection = isRoot
            ? nil : ReadCollection(uid: "some_parent", name: "some", createdAt: .now(), lastUpdated: .now())
        let subCollections = self.dummyCollectionItems.map { $0 |> \.parentID .~ collection?.uid }
        let scenario = StubReadItemUsecase.Scenario()
            |> \.myItems .~ .success(subCollections)
            |> \.collectionItems .~ .success(subCollections)
        let usecase = StubReadItemUsecase(scenario: scenario)
        return NavigateAndChageItemParentViewModelImple(targetItem: target,
                                                        currentCollection: collection,
                                                        unselectableCollectionID: nil,
                                                        readItemUsecase: usecase,
                                                        router: self,
                                                        coordinator: self.spyCoordinator)
    }
    
    override func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    func testViewModel_updateIsParentChangable_onlyWhenTargetParentIsNotCurrentCollection() {
        // given
        let subItemInRoot = self.targetItem(nil)
        let subItemInSomeCollection = self.targetItem("some_parent")
        
        // when + then
        XCTAssertEqual(self.makeViewModel(isRoot: true, target: subItemInRoot).isParentChangable, false)
        XCTAssertEqual(self.makeViewModel(isRoot: true, target: subItemInSomeCollection).isParentChangable, true)
        XCTAssertEqual(self.makeViewModel(isRoot: false, target: subItemInRoot).isParentChangable, true)
        XCTAssertEqual(self.makeViewModel(isRoot: true, target: subItemInRoot).isParentChangable, false)
    }
    
    func testViewModel_whenRootCollection_changeLinkItemParent() {
        // given
        let subItemInSomeCollection = self.targetItem("some_parent")
        
        let viewModel = self.makeViewModel(isRoot: true, target: subItemInSomeCollection)
        
        // when
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
    }
    
    func testViewModeL_whenNotRootCollection_changeLinkItemParent() {
        // given
        let subitemInRoot = self.targetItem(nil)
        
        let viewModel = self.makeViewModel(isRoot: false, target: subitemInRoot)
        
        // when
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
    }
}



extension NavigateCollectionViewModelTests {
    
    class SpyInverseNavigationCoordinator: CollectionInverseNavigationCoordinating {
        
        var didRequestedPrepareParentParams: CollectionInverseParentMakeParameter?
        func inverseNavigating(prepareParent parameter: CollectionInverseParentMakeParameter) {
            self.didRequestedPrepareParentParams = parameter
        }
    }
}

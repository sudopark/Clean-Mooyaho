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


class NavigateCollectionViewModelTests: BaseTestCase, WaitObservableEvents, NavigateCollectionRouting {
    
    var disposeBag: DisposeBag!
    var didMoveTo: ReadCollection?
    
    func moveToSubCollection(_ collection: ReadCollection) {
        self.didMoveTo = collection
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didMoveTo = nil
    }
    
    private var dummyCollectionItems: [ReadCollection] {
        return (1...10).map { ReadCollection.dummy($0) }
    }
    
    private var myCollectionItems: [ReadCollection] {
        return (30..<40).map { ReadCollection.dummy($0) }
    }
    
    private var dummyLinkItems: [ReadLink] {
        return (100..<110).map { ReadLink.dummy($0) }
    }
    
    private func makeViewModel(isRoot: Bool = true) -> NavigateCollectionViewModel {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.myItems .~ .success(self.myCollectionItems + dummyLinkItems)
            |> \.collectionItems .~ .success(self.dummyCollectionItems + dummyLinkItems)
        let usecase = StubReadItemUsecase(scenario: scenario)
        let collection = isRoot ? nil : ReadCollection.dummy(0)
        return NavigateCollectionViewModelImple(currentCollection: collection,
                                                readItemUsecase: usecase,
                                                router: self, listener: nil)
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
}

//
//  EditReadCollectionViewModelTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/03.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class EditReadCollectionViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var didUpdated: ((ReadCollection) -> Void)?
    var didClosed: Bool?
    var didErrorAlerted: Bool?
    var disposeBag: DisposeBag!
    var didRequestedStartWithPriority: ReadPriority?
    var didRequestStartWithCategories: [ItemCategory]?
    var mockSelectedPriority: ReadPriority?
    var mockSeelctedCategories: [ItemCategory]?
    private var editCollectionSceneInteractor: EditReadCollectionSceneInteractable?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didUpdated = nil
        self.didClosed = nil
        self.didErrorAlerted = nil
        self.editCollectionSceneInteractor = nil
        self.didRequestedStartWithPriority = nil
        self.didRequestStartWithCategories = nil
        self.mockSelectedPriority = nil
        self.mockSeelctedCategories = nil
    }
    
    private func makeViewModel(editCase: EditCollectionCase,
                               shouldSaveFail: Bool = false) -> EditReadCollectionViewModel {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.updateCollectionResult .~ (shouldSaveFail ? .failure(ApplicationErrors.invalid) : .success(()))
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        let viewModel = EditReadCollectionViewModelImple(parentID: "some",
                                                         editCase: editCase,
                                                         updateUsecase: stubUsecase,
                                                         router: self) { self.didUpdated?($0) }
        self.editCollectionSceneInteractor = viewModel
        return viewModel
    }
}


extension EditReadCollectionViewModelTests {
    
    func testViewModel_updateConfirmButtonByNameIsNotEmpty() {
        // given
        let expect = expectation(description: "콜렉션 이름 입려 여부에 따라 확인버튼 업데이트")
        expect.expectedFulfillmentCount = 3
        
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        // when
        let isConfirmables = self.waitElements(expect, for: viewModel.isConfirmable) {
            viewModel.enterName("some")
            viewModel.enterName("")
        }
        
        // then
        XCTAssertEqual(isConfirmables, [false, true, false])
    }
    
    func testViewModel_saveCollectionWithDescription() {
        // given
        let expect = expectation(description: "디스크립션과 함께 콜렉션 저장")
        var savedColelction: ReadCollection?
        let viewModel = self.makeViewModel(editCase: .makeNew)
        self.didUpdated = {
            savedColelction = $0
            expect.fulfill()
        }
        
        // when
        viewModel.enterName("name")
        viewModel.enterDescription("collection description")
        viewModel.confirmUpdate()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(savedColelction?.name, "name")
        XCTAssertEqual(savedColelction?.collectionDescription, "collection description")
        XCTAssertEqual(self.didClosed, true)
    }
    
    func testViewModel_whenSaveCollectionError_alertError() {
        // given
        let viewModel = self.makeViewModel(editCase: .makeNew, shouldSaveFail: true)
        
        // when
        viewModel.enterName("name")
        viewModel.confirmUpdate()
        
        // then
        XCTAssertEqual(self.didErrorAlerted, true)
    }
}


// MARK: - select priority
 
extension EditReadCollectionViewModelTests {
    
    func testViewModel_whenAfterSelectNewPriority_updatePriority() {
        // given
        let expect = expectation(description: "우선순위 선택 이후에 업데이트")
        let viewModel = self.makeViewModel(editCase: .makeNew)
        self.mockSelectedPriority = .beforeDying
        
        // when
        let newPriority = self.waitFirstElement(expect, for: viewModel.priority, skip: 1) {
            viewModel.addPriority()
        }
        
        // then
        XCTAssertEqual(newPriority, .beforeDying)
    }
    
    func testViewModel_requestAddPriority_startWithPreviousSelectedValue() {
        // given
        let expect = expectation(description: "이전에 선택했던 priority 값과 함께 우선순위 선택 요청")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        // when
        let priorities = self.waitElements(expect, for: viewModel.priority, skip: 1) {
            self.mockSelectedPriority = .afterAWhile
            viewModel.addPriority()
            
            self.mockSelectedPriority = .beforeDying
            viewModel.addPriority()
        }
        
        // then
        XCTAssertEqual(priorities.count, 2)
        XCTAssertEqual(self.didRequestedStartWithPriority, .afterAWhile)
    }
    
    func testViewModel_confirmSaveWithPriority() {
        // given
        let expect = expectation(description: "선택된 우선순위와 함께 콜렉션 생성")
        var newCollection: ReadCollection?
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        viewModel.enterName("some name")
        self.mockSelectedPriority = .afterAWhile
        viewModel.addPriority()
        
        self.didUpdated = {
            newCollection = $0
            expect.fulfill()
        }
        
        // when
        viewModel.confirmUpdate()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(newCollection?.priority, .afterAWhile)
    }
}


// MARK: - select categories

extension EditReadCollectionViewModelTests {
    
    func testViewModel_selectCategories() {
        // given
        let expect = expectation(description: "카테고리 선택 이후 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        // when
        let categories = self.waitElements(expect, for: viewModel.categories) {
            self.mockSeelctedCategories = [.dummy(0)]
            viewModel.addCategory()
        }
        
        // then
        XCTAssertEqual(categories, [
            [], [.dummy(0)]
        ])
    }
    
    func testViewModel_whenRequestSelectCategory_startWithPreviousSelectedValue() {
        // given
        let expect = expectation(description: "카테고리 선택 요청시에 이전에 선택한 정보 같이 요청")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        // when
        let _ = self.waitElements(expect, for: viewModel.categories) {
            self.mockSeelctedCategories = [.dummy(0)]
            viewModel.addCategory()
            
            self.mockSeelctedCategories = [.dummy(0), .dummy(1)]
            viewModel.addCategory()
        }
        
        // then
        XCTAssertEqual(self.didRequestStartWithCategories, [.dummy(0)])
    }
    
    func testViewModel_makeColelctionWithSelectedCategories() {
        // given
        let expect = expectation(description: "선택한 카테고리 정보와 함께 콜렉션 생성")
        var newCollection: ReadCollection?
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        viewModel.enterName("some name")
        self.mockSeelctedCategories = [.dummy(0)]
        viewModel.addCategory()
        
        self.didUpdated = {
            newCollection = $0
            expect.fulfill()
        }
        
        // when
        viewModel.confirmUpdate()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(newCollection?.categoryIDs, [ItemCategory.dummy(0).uid])
    }
}


extension EditReadCollectionViewModelTests: EditReadCollectionRouting {
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClosed = true
        completed?()
    }
    
    func alertError(_ error: Error) {
        self.didErrorAlerted = true
    }
    
    func selectPriority(startWith: ReadPriority?) {
        self.didRequestedStartWithPriority = startWith
        guard let mock = self.mockSelectedPriority else { return }
        self.editCollectionSceneInteractor?.editReadPriority(didSelect: mock)
    }
    
    func selectCategories(startWith: [ItemCategory]) {
        self.didRequestStartWithCategories = startWith
        guard let mock = self.mockSeelctedCategories else { return }
        self.editCollectionSceneInteractor?.editCategory(didSelect: mock)
    }
}

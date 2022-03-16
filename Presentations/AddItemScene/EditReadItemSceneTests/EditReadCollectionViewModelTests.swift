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


class EditReadCollectionViewModelTests: BaseTestCase, WaitObservableEvents, EditReadCollectionSceneListenable {
    
    var didUpdated: ((ReadCollection) -> Void)?
    var didClosed: Bool?
    var didErrorAlerted: Bool?
    var disposeBag: DisposeBag!
    var didRequestedStartWithPriority: ReadPriority?
    var didRequestStartWithCategories: [ItemCategory]?
    var didRequestStartWithRemindTime: TimeStamp?
    var didRequestStartWithRemindItem: ReadItem?
    var didRequestSelectParentCollection: Bool?
    var didRequestSelectParentCollectionStartWiths: [ReadCollection?] = []
    var mockSelectedPriority: ReadPriority?
    var mockSelectedCategories: [ItemCategory]?
    var mockSelectedRemindtime: TimeStamp?
    var mockSelectedRemindedItem: ReadItem?
    private var editCollectionSceneInteractor: EditReadCollectionSceneInteractable?
    
    private var spyRemindUsecase: StubReadRemindUsecase!
    
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
        self.didRequestStartWithRemindTime = nil
        self.didRequestStartWithRemindItem = nil
        self.didRequestSelectParentCollection = nil
        self.didRequestSelectParentCollectionStartWiths = []
        self.mockSelectedPriority = nil
        self.mockSelectedCategories = nil
        self.mockSelectedRemindtime = nil
        self.mockSelectedRemindedItem = nil
        self.spyRemindUsecase = nil
    }
    
    private func makeViewModel(parentID: String? = "some",
                               editCase: EditCollectionCase,
                               shouldSaveFail: Bool = false,
                               categories: [ItemCategory] = []) -> EditReadCollectionViewModelImple {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.updateCollectionResult .~ (shouldSaveFail ? .failure(ApplicationErrors.invalid) : .success(()))
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        let cateScenario = StubItemCategoryUsecase.Scenario()
            |> \.categories .~ [categories]
        let stubCategoryUsecase = StubItemCategoryUsecase(scenario: cateScenario)
        
        let remindScenario = StubReadRemindUsecase.Scenario()
        let stubRemindUsecase = StubReadRemindUsecase(scenario: remindScenario)
        self.spyRemindUsecase = stubRemindUsecase
        
        
        let viewModel = EditReadCollectionViewModelImple(parentID: parentID,
                                                         editCase: editCase,
                                                         readItemUsecase: stubUsecase,
                                                         remindUsecase: stubRemindUsecase,
                                                         categoriesUsecase: stubCategoryUsecase,
                                                         router: self,
                                                         listener: self)
        self.editCollectionSceneInteractor = viewModel
        return viewModel
    }
    
    func editReadCollection(didChange collection: ReadCollection) {
        self.didUpdated?(collection)
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


// MARK: - select remind

extension EditReadCollectionViewModelTests {
    
    func testViewModel_updateRemindBySelection() {
        // given
        let expect = expectation(description: "생성케이스일때 선택한 리마인드 업데이트")
        expect.expectedFulfillmentCount = 2
        let oldRemindTime = TimeStamp.now() + 1000
        let newRemindTime = TimeStamp.now() + 200
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        // when
        let times = self.waitElements(expect, for: viewModel.remindTime, skip: 1) {
            self.mockSelectedRemindtime = oldRemindTime
            viewModel.addRemind()
            
            self.mockSelectedRemindtime = newRemindTime
            viewModel.addRemind()
        }
        
        // then
        XCTAssertEqual(self.didRequestStartWithRemindTime, oldRemindTime)
        XCTAssertEqual(times, [oldRemindTime, newRemindTime])
    }
    
    func testViewModel_makeNewCollectionWithRemind() {
        // given
        let expect = expectation(description: "선택한 리마인드와 함께 콜렉션 생성")
        var newCollection: ReadCollection?
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        let remindTime = TimeStamp.now() + 1000
        viewModel.enterName("some name")
        self.mockSelectedRemindtime = remindTime
        viewModel.addRemind()
        
        self.didUpdated = {
            newCollection = $0
            expect.fulfill()
        }
        
        // when
        viewModel.confirmUpdate()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(newCollection?.remindTime, remindTime)
        XCTAssertEqual(self.spyRemindUsecase.didRemindScheduled, remindTime)
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
            self.mockSelectedCategories = [.dummy(0)]
            viewModel.addCategory()
        }
        
        // then
        let ids = categories.map { $0.map { $0.uid } }
        XCTAssertEqual(ids, [
            [], ["c:0"]
        ])
    }
    
    func testViewModel_whenRequestSelectCategory_startWithPreviousSelectedValue() {
        // given
        let expect = expectation(description: "카테고리 선택 요청시에 이전에 선택한 정보 같이 요청")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        // when
        let _ = self.waitElements(expect, for: viewModel.categories) {
            self.mockSelectedCategories = [.dummy(0)]
            viewModel.addCategory()
            
            self.mockSelectedCategories = [.dummy(0), .dummy(1)]
            viewModel.addCategory()
        }
        
        // then
        let didSelectedIDs = self.didRequestStartWithCategories?.map { $0.uid }
        XCTAssertEqual(didSelectedIDs, ["c:0"])
    }
    
    func testViewModel_makeColelctionWithSelectedCategories() {
        // given
        let expect = expectation(description: "선택한 카테고리 정보와 함께 콜렉션 생성")
        var newCollection: ReadCollection?
        let viewModel = self.makeViewModel(editCase: .makeNew)
        
        viewModel.enterName("some name")
        self.mockSelectedCategories = [.dummy(0)]
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

// MARK: - edit parent collection

extension EditReadCollectionViewModelTests {
    
    func testViewModel_provideParentCollectionName() {
        // given
        let expect = expectation(description: "parent collection 이름 제공")
        let colleciton = ReadCollection.dummy(10) |> \.parentID .~ "parent"
        let viewModel = self.makeViewModel(editCase: .edit(colleciton))
        
        // when
        let name = self.waitFirstElement(expect, for: viewModel.parentCollectionName)
        
        // then
        XCTAssertEqual(name, ReadCollection.dummy(0).name)
    }
    
    func testViewModel_whenChangeParentCollection_updateParentCollectionName() {
        // given
        let expect = expectation(description: "parent collection 변경하면 parent collection 이름도 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(parentID: nil, editCase: .makeNew)
        
        // when
        let dummyParent = ReadCollection.dummy(0)
        let names = self.waitElements(expect, for: viewModel.parentCollectionName) {
            viewModel.changeParentCollection()
            viewModel.navigateCollection(didSelectCollection: dummyParent)
            
            viewModel.changeParentCollection()
            viewModel.navigateCollection(didSelectCollection: nil)
        }
        
        // then
        XCTAssertEqual(self.didRequestSelectParentCollectionStartWiths.map { $0?.name }, [
            nil, dummyParent.name
        ])
        XCTAssertEqual(names, [
            "My Read Collections".localized, dummyParent.name, "My Read Collections".localized
        ])
    }
    
    func testViewModel_makeCollection_withParentCollectionInfo() async {
        // given
        let expect = expectation(description: "상위 콜렉션 정보와 함께 새 콜렉션 생성")
        let viewModel = self.makeViewModel(parentID: "initial parent collection", editCase: .makeNew)
    
        var newCollection: ReadCollection?
        self.didUpdated = {
            newCollection = $0
            expect.fulfill()
        }
        
        // when
        viewModel.enterName("some")
        viewModel.changeParentCollection()
        viewModel.navigateCollection(didSelectCollection: .dummy(100))
        viewModel.confirmUpdate()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(newCollection?.parentID, ReadCollection.dummy(100).uid)
    }
}


// MARK: - edit case

extension EditReadCollectionViewModelTests {
    
    var dummyCollection: ReadCollection {
        return ReadCollection(name: "some")
            |> \.collectionDescription .~ "description"
            |> \.priority .~ .afterAWhile
            |> \.categoryIDs .~ ["c:0", "c:1"]
    }
    
    func testViewModel_whenEditCase_showCurrentCollectionAttibutes() {
        // given
        let expect = expectation(description: "수정케이스의 경우 현재 카테고리 상태 노출")
        let viewModel = self.makeViewModel(editCase: .edit(self.dummyCollection),
                                           categories: [.dummy(0), .dummy(1)])
        
        // when
        let priorityAndCategorySource = Observable.combineLatest(
            viewModel.priority.compactMap { $0 },
            viewModel.categories.filter { $0.isNotEmpty }
        )
        let priorityAndCategory = self.waitFirstElement(expect, for: priorityAndCategorySource)
        
        // then
        XCTAssertEqual(viewModel.editCaseCollectionValue?.name, "some")
        XCTAssertEqual(viewModel.editCaseCollectionValue?.collectionDescription, "description")
        XCTAssertEqual(priorityAndCategory?.0, .afterAWhile)
        XCTAssertEqual(priorityAndCategory?.1.count, 2)
    }
    
    func testViewModel_whenEditCase_confirmUpdateWithNewValues() {
        // given
        let expect = expectation(description: "수정케이스의 새로운 값들과 함께 수정 요청")
        let viewModel = self.makeViewModel(editCase: .edit(self.dummyCollection),
                                           categories: [.dummy(0), .dummy(1)])
        var newCollection: ReadCollection?
        didUpdated = {
            newCollection = $0
            expect.fulfill()
        }
        
        // when
        viewModel.enterName("new name")
        self.mockSelectedCategories = [.dummy(0)]
        viewModel.addCategory()
        viewModel.confirmUpdate()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(newCollection?.name, "new name")
        XCTAssertEqual(newCollection?.collectionDescription, "description")
        XCTAssertEqual(newCollection?.priority, .afterAWhile)
        XCTAssertEqual(newCollection?.categoryIDs.count, 1)
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
        guard let mock = self.mockSelectedCategories else { return }
        self.editCollectionSceneInteractor?.editCategory(didSelect: mock)
    }
    
    func updateRemind(_ editCase: EditRemindCase) {
        switch editCase {
        case .select(let startWith):
            self.didRequestStartWithRemindTime = startWith
        case .edit(let item):
            self.didRequestStartWithRemindItem = item
        }
        
        if let time = self.mockSelectedRemindtime {
            self.editCollectionSceneInteractor?.editReadRemind(didSelect: Date(timeIntervalSince1970: time))
        } else if let remind = self.mockSelectedRemindedItem {
            self.editCollectionSceneInteractor?.editReadRemind(didUpdate: remind)
        }
    }
    
    func selectParentCollection(statrWith current: ReadCollection?) {
        self.didRequestSelectParentCollection = true
        self.didRequestSelectParentCollectionStartWiths.append(current)
    }
}

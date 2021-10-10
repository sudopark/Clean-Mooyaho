//
//  EditLinkItemViewModelTests.swift
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


// MARK: - BaseEditLinkItemViewModelTests

class BaseEditLinkItemViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var editCompleted: ((ReadLink) -> Void)?
    var didClose: Bool?
    var didErrorAlerted: Bool?
    var didRewind: Bool?
    var didSelectPriorityStartWith: ReadPriority?
    var didSelectCategoriesStartWith: [ItemCategory]?
    var selectPriorityMocking: ReadPriority?
    var selectCategoriesMocking: [ItemCategory]?
    private var editLinkItemSceneInteractable: EditLinkItemSceneInteractable?

    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didClose = nil
        self.didRewind = nil
        self.didErrorAlerted = nil
        self.didRewind = nil
        self.didSelectPriorityStartWith = nil
        self.selectPriorityMocking = nil
        self.editLinkItemSceneInteractable = nil
        self.didSelectCategoriesStartWith = nil
        self.selectCategoriesMocking = nil
    }
    
    var fullInfoPreview: LinkPreview {
        return LinkPreview(title: "title value", description: "description",
                           mainImageURL: "https://www.some url", iconURL: nil)
    }
    
    var insufficientPreview: LinkPreview {
        return LinkPreview(title: nil, description: nil,
                           mainImageURL: "https://www.some url", iconURL: nil)
    }
    
    func makeViewModel(editCase: EditLinkItemCase,
                       loadPreviewMocking: Observable<LinkPreview>? = nil,
                       shouldFailSave: Bool = false) -> EditLinkItemViewModel {
        
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.preview .~ .success(self.fullInfoPreview)
            |> \.updateLinkResult .~ (shouldFailSave ? .failure(ApplicationErrors.invalid) : .success(()))
        let usecaseStub = PrivateReadItemUsecaseStub(scenario: scenario)
            |> \.previewMocking .~ loadPreviewMocking
        
        let viewModel =  EditLinkItemViewModelImple(collectionID: "some",
                                                    editCase: editCase,
                                                    readUsecase: usecaseStub,
                                                    router: self) { self.editCompleted?($0) }
        self.editLinkItemSceneInteractable = viewModel
        return viewModel
    }
}


extension BaseEditLinkItemViewModelTests: EditLinkItemRouting {
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    func alertError(_ error: Error) {
        self.didErrorAlerted = true
    }
    
    func editPriority(startWith priority: ReadPriority?) {
        self.didSelectPriorityStartWith = priority
        guard let mocking = self.selectPriorityMocking else { return }
        self.editLinkItemSceneInteractable?.editReadPriority(didSelect: mocking)
    }
    
    func editCategory(startWith categories: [ItemCategory]) {
        self.didSelectCategoriesStartWith = categories
        guard let mocking = self.selectCategoriesMocking else { return }
        self.editLinkItemSceneInteractable?.editCategory(didSelect: mocking)
    }
    
    class PrivateReadItemUsecaseStub: StubReadItemUsecase {
        
        var previewMocking: Observable<LinkPreview>?
        
        override func loadLinkPreview(_ url: String) -> Observable<LinkPreview> {
            return previewMocking ?? super.loadLinkPreview(url)
        }
    }
    
    func requestRewind() {
        self.didRewind = true
    }
}


// MARK: - EditLinkItemViewModelTests + makeNew

class EditLinkItemViewModelTests_makeNew: BaseEditLinkItemViewModelTests {
    
    func makeViewModel(loadPreviewMocking: Observable<LinkPreview>? = nil,
                       shouldFailSave: Bool = false) -> EditLinkItemViewModel {
        let url = "https://www.naver.com"
        return self.makeViewModel(editCase: .makeNew(url: url),
                                  loadPreviewMocking: loadPreviewMocking,
                                  shouldFailSave: shouldFailSave)
    }
}

extension EditLinkItemViewModelTests_makeNew {
    
    func testViewModel_rewind() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.rewind()
        
        // then
        XCTAssertEqual(self.didRewind, true)
    }
    
    func testViewModel_prepareLinkPreview() {
        // given
        let expect = expectation(description: "preview 준비하여 출력")
        expect.expectedFulfillmentCount = 2
        
        let viewModel = self.makeViewModel()
        
        // when
        let previews = self.waitElements(expect, for: viewModel.linkPreviewStatus) {
            viewModel.preparePreview()
        }
        
        // then
        XCTAssertEqual(previews.first?.isLoading, true)
        XCTAssertEqual(previews.last?.isLoaded, true)
    }
    
    func testViewModel_loadPreviewFail() {
        // given
        let expect = expectation(description: "preview 준비하여 출력")
        expect.expectedFulfillmentCount = 2
        
        let viewModel = self.makeViewModel(loadPreviewMocking: .error(ApplicationErrors.invalid))
        
        // when
        let previews = self.waitElements(expect, for: viewModel.linkPreviewStatus) {
            viewModel.preparePreview()
        }
        
        // then
        XCTAssertEqual(previews.first?.isLoading, true)
        XCTAssertEqual(previews.last?.isLoadFail, true)
    }
    
    func testViewModel_whenInsuffisientPreview_regardAsLoadFail() {
        // given
        let expect = expectation(description: "preview 정보가 불충분할때는 로딩 실패로 처리")
        expect.expectedFulfillmentCount = 2
        
        let viewModel = self.makeViewModel(loadPreviewMocking: .just(self.insufficientPreview))
        
        // when
        let previews = self.waitElements(expect, for: viewModel.linkPreviewStatus) {
            viewModel.preparePreview()
        }
        
        // then
        XCTAssertEqual(previews.first?.isLoading, true)
        XCTAssertEqual(previews.last?.isLoadFail, true)
    }
}

extension EditLinkItemViewModelTests_makeNew {
    
    func testViewModel_whenPreviewLoaded_updateTitle() {
        // given
        let expect = expectation(description: "preview load 이후에 타이틀 업데이트")
        let viewModel = self.makeViewModel()
        
        // when
        let suggestedTitle = self.waitFirstElement(expect, for: viewModel.itemSuggestedTitle) {
            viewModel.preparePreview()
        }
        
        // then
        XCTAssertNotNil(suggestedTitle)
        XCTAssertEqual(suggestedTitle, self.fullInfoPreview.title)
    }
    
    func testViewModel_whenUserEnterSomeTitle_doNotUpdateTitleAfterPreviewLoaded() {
        // given
        let expect = expectation(description: "유저가 입력중인 값이 있을때는 preview 로드 완료 이후에 타이틀 업데이트 안함")
        expect.isInverted = true
        let fakePreview = PublishSubject<LinkPreview>()
        let viewModel = self.makeViewModel(loadPreviewMocking: fakePreview)
        
        // when
        let suggestedTitle = self.waitFirstElement(expect, for: viewModel.itemSuggestedTitle) {
            viewModel.preparePreview()
            viewModel.enterCustomName("custom name")
            fakePreview.onNext(self.fullInfoPreview)
        }
        
        // then
        XCTAssertNil(suggestedTitle)
    }
}

// MARK: - select priority

extension EditLinkItemViewModelTests_makeNew {
    
    func testViewModel_requestSelectPriority() {
        // given
        let expect = expectation(description: "priority 선택")
        let viewModel = self.makeViewModel()
        
        // when
        let priority = self.waitFirstElement(expect, for: viewModel.priority, skip: 1) {
            self.selectPriorityMocking = .beforeDying
            viewModel.editPriority()
        }
        
        // then
        XCTAssertEqual(priority, .beforeDying)
    }
    
    func testViewModel_changeSelectedPriority() {
        // given
        let expect = expectation(description: "우선순위 선택 반복")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let priorities = self.waitElements(expect, for: viewModel.priority, skip: 1) {
            self.selectPriorityMocking = .afterAWhile
            viewModel.editPriority()
            
            self.selectPriorityMocking = .beforeGoToBed
            viewModel.editPriority()
        }
        
        // then
        XCTAssertEqual(priorities.first, .afterAWhile)
        XCTAssertEqual(priorities.last, .beforeGoToBed)
        XCTAssertEqual(self.didSelectPriorityStartWith, .afterAWhile)
    }
}

// MARK: - select categories

extension EditLinkItemViewModelTests_makeNew {
    
    func testViewModel_requestSelectCategories() {
        // given
        let expect = expectation(description: "category 선택")
        let viewModel = self.makeViewModel()
        
        // when
        let categories = self.waitFirstElement(expect, for: viewModel.categories, skip: 1) {
            self.selectCategoriesMocking = [.dummy(0)]
            viewModel.editCategory()
        }
        
        // then
        XCTAssertEqual(categories, [.dummy(0)])
    }
    
    func testViewModel_changeSelectedCategories() {
        // given
        let expect = expectation(description: "category 선택 반복")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let categoryLists = self.waitElements(expect, for: viewModel.categories, skip: 1) {
            self.selectCategoriesMocking = [.dummy(0)]
            viewModel.editCategory()
            
            self.selectCategoriesMocking = [.dummy(0), .dummy(1)]
            viewModel.editCategory()
        }
        
        // then
        XCTAssertEqual(categoryLists.first, [.dummy(0)])
        XCTAssertEqual(categoryLists.last, [.dummy(0), .dummy(1)])
        XCTAssertEqual(self.didSelectCategoriesStartWith, [.dummy(0)])
    }
}


extension EditLinkItemViewModelTests_makeNew {
    
    func testViewModel_addLinkItem() {
        // given
        let expect = expectation(description: "link item 추가")
        var newLink: ReadLink?
        let viewModel = self.makeViewModel()
        
        viewModel.enterCustomName("custom name")
        self.selectPriorityMocking = .afterAWhile
        viewModel.editPriority()
        self.selectCategoriesMocking = [.dummy(0)]
        viewModel.editCategory()
        
        self.editCompleted = {
            newLink = $0
            expect.fulfill()
        }
        
        // when
        viewModel.confirmSave()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(newLink?.priority, .afterAWhile)
        XCTAssertEqual(newLink?.customName, "custom name")
        XCTAssertEqual(newLink?.categoryIDs, [ItemCategory.dummy(0).uid])
    }
    
    func testViewModel_whenSaveItemFail_showError() {
        // given
        let viewModel = self.makeViewModel(shouldFailSave: true)
        
        // when
        viewModel.confirmSave()
        
        // then
        XCTAssertEqual(self.didErrorAlerted, true)
    }
    
    func testViewModel_whenSaving_showProcessing() {
        // given
        let expect = expectation(description: "저장중에는 상태 표시")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isProcessings = self.waitElements(expect, for: viewModel.isProcessing) {
            viewModel.preparePreview()
            viewModel.confirmSave()
        }
        
        // then
        XCTAssertEqual(isProcessings, [false, true, false])
    }
}


private extension LoadPreviewStatus {
    
    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
    
    var isLoaded: Bool {
        guard case .loaded = self else { return false }
        return true
    }
    
    var isLoadFail: Bool {
        guard case .loadFail = self else { return false }
        return true
    }
}

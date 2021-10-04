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
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didUpdated = nil
        self.didClosed = nil
        self.didErrorAlerted = nil
    }
    
    private func makeViewModel(editCase: EditCollectionCase,
                               shouldSaveFail: Bool = false) -> EditReadCollectionViewModel {
        
        let scenario = StubReadItemUsecase.Scenario()
            |> \.updateCollectionResult .~ (shouldSaveFail ? .failure(ApplicationErrors.invalid) : .success(()))
        let stubUsecase = StubReadItemUsecase(scenario: scenario)
        
        return EditReadCollectionViewModelImple(parentID: "some",
                                                editCase: editCase,
                                                updateUsecase: stubUsecase,
                                                router: self) { self.didUpdated?($0) }
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


extension EditReadCollectionViewModelTests: EditReadCollectionRouting {
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClosed = true
        completed?()
    }
    
    func alertError(_ error: Error) {
        self.didErrorAlerted = true
    }
}

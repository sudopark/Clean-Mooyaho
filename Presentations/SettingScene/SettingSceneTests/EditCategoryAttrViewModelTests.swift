//
//  EditCategoryAttrViewModelTests.swift
//  SettingSceneTests
//
//  Created by sudo.park on 2021/12/04.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import SettingScene


class EditCategoryAttrViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: SpyRouter!
    private var spyListner: SpyListner!
    private var spyUsecase: StubItemCategoryUsecase!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.spyListner = nil
        self.spyUsecase = nil
    }
    
    private var dummyCategory: ItemCategory = {
        return ItemCategory(name: "old name", colorCode: "old color")
            |> \.ownerID .~ "owner"
    }()
    
    private func makeViewModel(saveResult: Result<Void, Error> = .success(())) -> EditCategoryAttrViewModelImple {
        
        let router = SpyRouter()
        self.spyRouter = router
        
        let listner = SpyListner()
        self.spyListner = listner
        
        let scenario = StubItemCategoryUsecase.Scenario()
            |> \.updateCategoryWithValidatingReuslt .~ saveResult
        let usecase = StubItemCategoryUsecase(scenario: scenario)
        self.spyUsecase = usecase
        
        return EditCategoryAttrViewModelImple(category: self.dummyCategory, categoryUsecase: usecase,
                                              router: router, listener: listner)
    }
}


extension EditCategoryAttrViewModelTests {
    
    // 이름 입력 여부에 따라 확인가능여부 업데이트
    func testViewModel_updateConfirmable_byEnteringName() {
        // given
        let expect = expectation(description: "이름을 입력해야만 변경내용 저장 가능")
        expect.expectedFulfillmentCount = 4
        let viewModel = self.makeViewModel()
        
        // when
        let isEnables = self.waitElements(expect, for: viewModel.isChangeSavable) {
            viewModel.enter(name: "")
            viewModel.enter(name: "some")
            viewModel.enter(name: "")
        }
        
        // then
        XCTAssertEqual(isEnables, [true, false, true, false])
    }
    
    // 색상변경 요청 및 업데이트
    func testViewModel_updateColor() {
        // given
        let expect = expectation(description: "새로운 색상으로 변경")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let colors = self.waitElements(expect, for: viewModel.selectedColorCode) {
            viewModel.selectNewColor()
            viewModel.colorSelect(didSeelctColor: "new color")
        }
        
        // then
        XCTAssertEqual(colors, ["old color", "new color"])
    }
}

extension EditCategoryAttrViewModelTests {
    
    // 삭제시 컨펌보이고 삭제한뒤에 화면 닫음 -> 리스너로 알림
    func testViewModel_deleteCategoryWithConfirm() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.delete()
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertConfirm, true)
        XCTAssertEqual(self.spyRouter.didClose, true)
        XCTAssertEqual(self.spyListner.didRemoveNotified, true)
    }
    
    // 변경사항 저장시에 저장하고 화면 닫음
    func testViewModel_whenAfterSaveChanges_closeAndNotifyItemUdpated() {
        // given
        let viewmodel = self.makeViewModel()
        
        // when
        viewmodel.confirmSaveChange()
        
        // then
        XCTAssertEqual(self.spyRouter.didClose, true)
        XCTAssertEqual(self.spyListner.didChangNotified, true)
    }
    
    func testViewModel_saveChange_withOnlyChangeName() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.enter(name: "new name")
        viewModel.confirmSaveChange()
        
        // then
        let old = self.dummyCategory
        let new = self.spyUsecase.didUpdateRequestedCategory
        XCTAssertEqual(new?.uid, old.uid)
        XCTAssertEqual(new?.ownerID, old.ownerID)
        XCTAssertEqual(new?.createdAt, old.createdAt)
        XCTAssertEqual(new?.name, "new name")
        XCTAssertEqual(new?.colorCode, old.colorCode)
    }
    
    func testViewModel_saveChange_withOnlyChangeColor() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.selectNewColor()
        viewModel.colorSelect(didSeelctColor: "new color")
        viewModel.confirmSaveChange()
        
        // then
        let old = self.dummyCategory
        let new = self.spyUsecase.didUpdateRequestedCategory
        XCTAssertEqual(new?.uid, old.uid)
        XCTAssertEqual(new?.ownerID, old.ownerID)
        XCTAssertEqual(new?.createdAt, old.createdAt)
        XCTAssertEqual(new?.name, old.name)
        XCTAssertEqual(new?.colorCode, "new color")
    }
    
    func testViewModel_saveChange_withChangeNameAndColor() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.enter(name: "new name")
        viewModel.selectNewColor()
        viewModel.colorSelect(didSeelctColor: "new color")
        viewModel.confirmSaveChange()
        
        // then
        let old = self.dummyCategory
        let new = self.spyUsecase.didUpdateRequestedCategory
        XCTAssertEqual(new?.uid, old.uid)
        XCTAssertEqual(new?.ownerID, old.ownerID)
        XCTAssertEqual(new?.createdAt, old.createdAt)
        XCTAssertEqual(new?.name, "new name")
        XCTAssertEqual(new?.colorCode, "new color")
    }
    
    // 저장 실패시에 에러알림
    func testViewModel_whenSaveFail_alertError() {
        // given
        let viewModel = self.makeViewModel(saveResult: .failure(ApplicationErrors.invalid))
        
        // when
        viewModel.confirmSaveChange()
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertError, true)
    }
    
    func testViewModel_whenSaveFailDueToSameName_alertDuplicating() {
        // given
        let viewModel = self.makeViewModel(saveResult: .failure(SameNameCategoryExistsError()))
        
        // when
        viewModel.confirmSaveChange()
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertNameDuplicated, true)
    }
}


extension EditCategoryAttrViewModelTests {
    
    class SpyRouter: EditCategoryAttrRouting {
        
        var didRequestSelectNewColor: Bool?
        func selectNewColor(_ stratWith: String) {
            self.didRequestSelectNewColor = true
        }
        
        var didAlertConfirm: Bool?
        func alertForConfirm(_ form: AlertForm) {
            self.didAlertConfirm = true
            form.confirmed?()
        }
        
        var didClose: Bool?
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.didClose = true
        }
        
        var didAlertError: Bool?
        func alertError(_ error: Error) {
            self.didAlertError = true
        }
        
        var didAlertNameDuplicated: Bool?
        func alertNameDuplicated(_ name: String) {
            self.didAlertNameDuplicated = true
        }
    }
    
    class SpyListner: EditCategoryAttrSceneListenable {
        
        var didRemoveNotified: Bool?
        func editCategory(didDeleted categoryID: String) {
            self.didRemoveNotified = true
        }
        
        var didChangNotified: Bool?
        func editCategory(didChaged category: ItemCategory) {
            self.didChangNotified = true
        }
    }
}

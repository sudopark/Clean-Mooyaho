//
//  EditProfileViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2021/06/01.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import StubUsecases

@testable import MemberScenes


class EditProfileViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockMemberUsecase: MockMemberUsecase!
    var spyRouter: SpyRouter!
    var viewModel: EditProfileViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockMemberUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = .init(usecase: self.mockMemberUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockMemberUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


// MARK: - test view initial state

extension EditProfileViewModelTests {
    
    func testViewModel_showPreviousEnteredImage() {
        // given
        let expect = expectation(description: "이전에 입력한 프로필 이미지 소스 방출")
        self.mockMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            let member = Member(uid: "uid", nickName: nil, icon: .emoji("⛳️"))
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let source = self.waitFirstElement(expect, for: self.viewModel.profileImageSource)
        
        // then
        if case .emoji = source {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 값이 아님")
        }
    }
    
    // 셀뷰모델 두개 방출
    func testViewModel_initialCellViewModels() {
        // given
        let expect = expectation(description: "셀뷰모델 구성")
        self.mockMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            let member = Member(uid: "uid", nickName: "nick", icon: .emoji("⛳️"))
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let types = self.waitFirstElement(expect, for: self.viewModel.cellTypes)
        
        // then
        guard let first = types?.first, let second = types?.last else {
            XCTFail("셀뷰모델이 불충분함")
            return
        }
        XCTAssertEqual(first, .nickName)
        XCTAssertEqual(self.viewModel.previousInputValue(for: first), "nick")
        XCTAssertEqual(self.viewModel.previousInputValue(for: second), nil)
    }
}

extension EditProfileViewModelTests {
    
    // 닉네임 입력 안되어있을때 입력하면 확인버튼 활성화
    func testViewModel_whenActiveSaveButton_nickNameIsNotNil() {
        // given
        let expect = expectation(description: "닉네임이 nil이 아닌 경우에만 저장버튼 활성화")
        expect.expectedFulfillmentCount = 3
        self.mockMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            let member = Member(uid: "uid", nickName: nil, icon: .emoji("⛳️"))
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let isSavables = self.waitElements(expect, for: self.viewModel.isSavable) {
            self.viewModel.inputTextChanges(type: .introduction, to: "some")
            self.viewModel.inputTextChanges(type: .nickName, to: "")
            self.viewModel.inputTextChanges(type: .nickName, to: "nick")
            self.viewModel.inputTextChanges(type: .nickName, to: nil)
        }
        
        // then
        XCTAssertEqual(isSavables, [false, true, false])
    }
    
    func testViewModel_whenEditAndChangeOccurs_updateSavable() {
        // given
        let expect = expectation(description: "수정모드에서 수정내역이 발생 + 닉네임이 있을때만 저장버튼 활성화")
        expect.expectedFulfillmentCount = 4
        
        self.mockMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            var member = Member(uid: "uid", nickName: "some", icon: .emoji("⛳️"))
            member.introduction = "old"
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let isSavables = self.waitElements(expect, for: self.viewModel.isSavable) {
            self.viewModel.inputTextChanges(type: .introduction, to: "new")     // true
            self.viewModel.inputTextChanges(type: .nickName, to: nil)           // false
            self.viewModel.inputTextChanges(type: .introduction, to: "old")         // false -> ignored
            self.viewModel.inputTextChanges(type: .nickName, to: "some")            // false -> ignored
            self.viewModel.inputTextChanges(type: .introduction, to: "new")     // true
        }
        
        // then
        XCTAssertEqual(isSavables, [false, true, false, true])
    }
    
    func testViewModel_whenNewImageSourceEntered_updateSavable() {
        // given
        let expect = expectation(description: "이미지 입력시에는 저장가능여부 업데이트")
        expect.expectedFulfillmentCount = 2
        
        self.mockMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            var member = Member(uid: "uid", nickName: "some", icon: nil)
            member.introduction = "old"
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let isSavables = self.waitElements(expect, for: self.viewModel.isSavable) {
            self.viewModel.selectEmoji("😂")
            self.viewModel.inputTextChanges(type: .introduction, to: "new")
            self.viewModel.inputTextChanges(type: .introduction, to: "old")
        }
        
        // then
        XCTAssertEqual(isSavables, [false, true])
    }
}

extension EditProfileViewModelTests {
    
    private func registerViewModelSavable() {
        self.mockMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            var member = Member(uid: "uid", nickName: "some", icon: nil)
            member.introduction = "old"
            return member
        }
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        self.viewModel.inputTextChanges(type: .introduction, to: "new")
    }
    
    func testViewModel_whenSaveChanges_showIsSaving() {
        // given
        let expect = expectation(description: "이미지 데이터와 함께 프로파일 변경정보 저장")
        expect.expectedFulfillmentCount = 3
        
        self.registerViewModelSavable()
        
        // when
        let isSavings = self.waitElements(expect, for: self.viewModel.isSaveChanges) {
            self.viewModel.selectMemoji(Data())
            self.viewModel.saveChanges()
            self.mockMemberUsecase.updateStatus.onNext(.pending)
            self.mockMemberUsecase.updateStatus.onNext(.updating(0.1))
            self.mockMemberUsecase.updateStatus.onNext(.finished)
        }
        
        // then
        XCTAssertEqual(isSavings, [false, true, false])
    }
    
    // 저장 완료시 토스트 노출하고 화면 닫기
    func testViewModel_whenSaveFinished_closeAndEmitEvent() {
        // given
        let expect = expectation(description: "저장 완료시에 화면 닫고 외부로 이벤트 전파")
        expect.expectedFulfillmentCount = 2
        
        self.registerViewModelSavable()
        
        self.spyRouter.called(key: "closeScene") { _ in
            expect.fulfill()
        }
        self.viewModel.editCompleted.subscribe(onNext: {
            expect.fulfill()
        })
        .disposed(by: self.disposeBag)
        
        // when
        self.viewModel.saveChanges()
        self.mockMemberUsecase.updateStatus.onNext(.finished)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 사진 업로드 실패했으면 프로필은 일단 저장하고 에러 토스트 -> 이미지에 오버레이로 실패 표시
    func testViewModel_whenFailOnlyUploadImage_showToastAndNotClose() {
        // given
        let expect = expectation(description: "사진 저장만 실패한 경우에는 토스트 노출하고 화면은 안닫음")
        
        self.registerViewModelSavable()
        
        self.spyRouter.called(key: "showToast") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.selectMemoji(Data())
        self.viewModel.saveChanges()
        self.mockMemberUsecase.updateStatus.onNext(.finishedWithImageUploadFail(ApplicationErrors.invalid))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenFailUpdate_showError() {
        // given
        let expect = expectation(description: "프로필 업데이트에 실패한 경우에는 에러 알림")
        
        self.registerViewModelSavable()
        
        self.spyRouter.called(key: "alertError") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.selectMemoji(Data())
        self.viewModel.saveChanges()
        self.mockMemberUsecase.updateStatus.onError(ApplicationErrors.invalid)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_closeScene() {
        // given
        let expect = expectation(description: "현재화면 닫음")
        
        self.spyRouter.called(key: "closeScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestCloseScene()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenSaveChangesAndRequestClose_showAlert() {
        // given
        let expect = expectation(description: "프로필 저장중에 화면 닫으려할경우 컨펌알럿 노출 필요")
        
        self.spyRouter.called(key: "alertForConfirm") { _ in
            expect.fulfill()
        }
        
        // when
        self.registerViewModelSavable()
        self.viewModel.saveChanges()
        self.viewModel.requestCloseScene()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension EditProfileViewModelTests {
    
    class SpyRouter: EditProfileRouting, Mocking {
        
        func showToast(_ message: String) {
            self.verify(key: "showToast")
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.verify(key: "closeScene")
            completed?()
        }
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
        
        func alertForConfirm(_ form: AlertForm) {
            self.verify(key: "alertForConfirm")
        }
    }
}

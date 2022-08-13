//
//  EditProfileViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2021/06/01.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

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
        self.registerMember(Member(uid: "uid", nickName: nil, icon: .emoji("⛳️")))
        
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
        self.registerMember(Member(uid: "uid", nickName: "nick", icon: .emoji("⛳️")))
        
        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels)
        
        // then
        XCTAssertEqual(cellViewModels, [
            .init(inputType: .nickname, value: "nick", isRequire: true),
            .init(inputType: .intro, value: nil, isRequire: false)
        ])
    }
    
    func testViewModel_clearIntro() {
        // given
        let expect = expectation(description: "자기소개 초기화")
        expect.expectedFulfillmentCount = 2
        var member = Member(uid: "uid", nickName: "some", icon: nil)
        member.introduction = "old_value"
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModels) {
            self.viewModel.requestChangeProperty(.intro)
            self.spyRouter.capturedListener?.textInput(didEntered: "")
        }
        
        // then
        XCTAssertEqual(cvmLists, [
            [
                .init(inputType: .nickname, value: "some", isRequire: true),
                .init(inputType: .intro, value: "old_value", isRequire: false)
            ],
            [
                .init(inputType: .nickname, value: "some", isRequire: true),
                .init(inputType: .intro, value: nil, isRequire: false)
            ]
        ])
    }
}

extension EditProfileViewModelTests {
    
    // 닉네임 입력 안되어있을때 입력하면 확인버튼 활성화
    func testViewModel_whenActiveSaveButton_nickNameIsNotNil() {
        // given
        let expect = expectation(description: "닉네임이 있는 경우에만 저장버튼 활성화")
        expect.expectedFulfillmentCount = 3
        self.registerMember(Member(uid: "uid", nickName: nil, icon: .emoji("⛳️")))

        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let isSavables = self.waitElements(expect, for: self.viewModel.isSavable) {
            self.viewModel.requestChangeProperty(.intro)
            self.spyRouter.capturedListener?.textInput(didEntered: "some")
            
            self.viewModel.requestChangeProperty(.nickname)
            self.spyRouter.capturedListener?.textInput(didEntered: "nick")
            
            self.viewModel.requestChangeProperty(.nickname)
            self.spyRouter.capturedListener?.textInput(didEntered: "")
        }

        // then
        XCTAssertEqual(isSavables, [false, true, false])
    }
    
    func testViewModel_whenNewImageSourceEntered_updateSavable() {
        // given
        let expect = expectation(description: "이미지 입력시에는 저장가능여부 업데이트")
        var member = Member(uid: "uid", nickName: "some", icon: nil)
        member.introduction = "old"
        self.registerMember(member)

        // when
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        let isSavables = self.waitElements(expect, for: self.viewModel.isSavable) {
            self.viewModel.selectEmoji(didSelect: "🤑")
            self.viewModel.requestChangeProperty(.intro)
            self.spyRouter.capturedListener?.textInput(didEntered: "new")
            
            self.viewModel.requestChangeProperty(.intro)
            self.spyRouter.capturedListener?.textInput(didEntered: "old")
        }

        // then
        XCTAssertEqual(isSavables, [true])
    }
}

extension EditProfileViewModelTests {
    
    func testViewModel_requestChooseImageSource() {
        // given
        // when
        self.viewModel.requestChangeThumbnail()
        
        // then
        XCTAssertNotNil(self.spyRouter.didRequestedChooseImageSourceForm)
    }
    
    func testViewModel_selectProfilePhoto() {
        // given
        let expect = expectation(description: "이미지 선택")
        var member = Member(uid: "uid", nickName: "some", icon: nil)
        member.introduction = "old"
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        // when
        let thumnail = self.waitFirstElement(expect, for: self.viewModel.profileImageSource, skip: 1) {
            self.viewModel.requestChangeThumbnail()
            self.viewModel.imagePicker(didSelect: "path", imageSize: .init(100, 100))
        }
        
        // then
        XCTAssertEqual(thumnail, .imageSource(.init(path: "path", size: .init(100, 100))))
    }
    
    func testViewModel_selectEmoji() {
        // given
        let expect = expectation(description: "이미지 선택")
        var member = Member(uid: "uid", nickName: "some", icon: nil)
        member.introduction = "old"
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        // when
        let thumnail = self.waitFirstElement(expect, for: self.viewModel.profileImageSource, skip: 1) {
            self.viewModel.requestChangeThumbnail()
            self.viewModel.selectEmoji(didSelect: "😿")
        }
        
        // then
        XCTAssertEqual(thumnail, .emoji("😿"))
    }
}

extension EditProfileViewModelTests {
    
    private func registerMember(_ member: Member) {
        self.mockMemberUsecase.register(type: Maybe<Member>.self, key: "reloadCurrentMember") {
            return .just(member)
        }
    }
    
    func testViewModel_updateProfile_fromEmptyProperties() {
        // given
        let expect = expectation(description: "아무것도 입력 안했던 상태에서 프로필 업데이트")
        let member = Member(uid: "some", nickName: nil, icon: nil)
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        self.viewModel.requestChangeProperty(.nickname)
        self.spyRouter.capturedListener?.textInput(didEntered: "nick")
        
        self.viewModel.requestChangeProperty(.intro)
        self.spyRouter.capturedListener?.textInput(didEntered: "intro")
        
        self.viewModel.requestChangeThumbnail()
        self.viewModel.selectEmoji(didSelect: "🤑")
        
        var fields: [MemberUpdateField]?; var params: ImageUploadReqParams?
        self.mockMemberUsecase.called(key: "updateCurrent") { any in
            guard let pair = any as? ([MemberUpdateField], ImageUploadReqParams?) else { return }
            fields = pair.0; params = pair.1
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(params, .emoji("🤑"))
        XCTAssertEqual(fields, [.nickName("nick"), .introduction("intro")])
    }
    
    func testViewModel_updateProfile_onlyNiickName() {
        // given
        let expect = expectation(description: "닉네임만 프로필 업데이트")
        let member = Member(uid: "some", nickName: "old", icon: nil)
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        self.viewModel.requestChangeProperty(.nickname)
        self.spyRouter.capturedListener?.textInput(didEntered: "new")
        
        var fields: [MemberUpdateField]?; var params: ImageUploadReqParams?
        self.mockMemberUsecase.called(key: "updateCurrent") { any in
            guard let pair = any as? ([MemberUpdateField], ImageUploadReqParams?) else { return }
            fields = pair.0; params = pair.1
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertNil(params)
        XCTAssertEqual(fields, [.nickName("new")])
    }
    
    func testViewModel_updateProfile_onlyProfileAsPhoto() {
        // given
        let expect = expectation(description: "프사만 사진으로 업데이트")
        let member = Member(uid: "some", nickName: "nick", icon: nil)
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        self.viewModel.requestChangeThumbnail()
        self.viewModel.imagePicker(didSelect: "path", imageSize: .init(100, 100))
        
        var fields: [MemberUpdateField]?; var params: ImageUploadReqParams?
        self.mockMemberUsecase.called(key: "updateCurrent") { any in
            guard let pair = any as? ([MemberUpdateField], ImageUploadReqParams?) else { return }
            fields = pair.0; params = pair.1
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(params, .file("path", needCopyTemp: true, size: .init(100, 100)))
        XCTAssertEqual(fields, [])
    }
    
    func testViewModel_updateProfile_onlyProfileAsEmoji() {
        // given
        let expect = expectation(description: "프사만 이모지로 업데이트")
        let member = Member(uid: "some", nickName: "nick", icon: nil)
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        self.viewModel.requestChangeThumbnail()
        self.viewModel.selectEmoji(didSelect: "🤑")
        
        var fields: [MemberUpdateField]?; var params: ImageUploadReqParams?
        self.mockMemberUsecase.called(key: "updateCurrent") { any in
            guard let pair = any as? ([MemberUpdateField], ImageUploadReqParams?) else { return }
            fields = pair.0; params = pair.1
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertEqual(params, .emoji("🤑"))
        XCTAssertEqual(fields, [])
    }
    
    func testViewModel_updateProfile_onlyIntro() {
        // given
        let expect = expectation(description: "소개만 업데이트")
        let member = Member(uid: "some", nickName: "old", icon: nil)
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        self.viewModel.requestChangeProperty(.intro)
        self.spyRouter.capturedListener?.textInput(didEntered: "some")
        
        var fields: [MemberUpdateField]?; var params: ImageUploadReqParams?
        self.mockMemberUsecase.called(key: "updateCurrent") { any in
            guard let pair = any as? ([MemberUpdateField], ImageUploadReqParams?) else { return }
            fields = pair.0; params = pair.1
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertNil(params)
        XCTAssertEqual(fields, [.introduction("some")])
    }
    
    func testViewModel_updateProfile_deleteIntro() {
        // given
        let expect = expectation(description: "소개만 업데이트 - 삭제")
        let member = Member(uid: "some", nickName: "old", icon: nil) |> \.introduction .~ "some"
        self.registerMember(member)
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        
        self.viewModel.requestChangeProperty(.intro)
        self.spyRouter.capturedListener?.textInput(didEntered: "")
        
        var fields: [MemberUpdateField]?; var params: ImageUploadReqParams?
        self.mockMemberUsecase.called(key: "updateCurrent") { any in
            guard let pair = any as? ([MemberUpdateField], ImageUploadReqParams?) else { return }
            fields = pair.0; params = pair.1
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.wait(for: [expect], timeout: self.timeout)
        
        // then
        XCTAssertNil(params)
        XCTAssertEqual(fields, [.introduction(nil)])
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
        
        self.registerMember(Member(uid: "some", nickName: nil, icon: nil))
        self.viewModel = .init(usecase: self.mockMemberUsecase, router: self.spyRouter)
        self.viewModel.requestChangeProperty(.nickname)
        self.spyRouter.capturedListener?.textInput(didEntered: "nick")
        
        self.spyRouter.called(key: "alertForConfirm") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.saveChanges()
        self.viewModel.requestCloseScene()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension EditProfileViewModelTests {
    
    final class SpyRouter: EditProfileRouting, Mocking, @unchecked Sendable {
        
        var capturedListener: TextInputSceneListenable?
        func editText(mode: TextInputMode, listener: TextInputSceneListenable) {
            self.capturedListener = listener
        }
        
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
        
        var didRequestedChooseImageSourceForm: ActionSheetForm?
        func chooseProfileImageSource(_ form: ActionSheetForm) {
            self.didRequestedChooseImageSourceForm = form
        }
        
        var didRequestSeelctPhoto: Bool = false
        func selectPhoto() {
            self.didRequestSeelctPhoto = true
        }
        
        var didRequestSelectEmoji: Bool = false
        func selectEmoji() {
            self.didRequestSelectEmoji = true
        }
    }
}

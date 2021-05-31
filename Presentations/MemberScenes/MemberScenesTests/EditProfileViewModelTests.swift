//
//  EditProfileViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2021/06/01.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import StubUsecases

@testable import MemberScenes


class EditProfileViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubMemberUsecase: StubMemberUsecase!
    var spyRouter: SpyRouter!
    var viewModel: EditProfileViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubMemberUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = .init(usecase: self.stubMemberUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubMemberUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


// MARK: - test view initial state

extension EditProfileViewModelTests {
    
    func testViewModel_showPreviousEnteredImage() {
        // given
        let expect = expectation(description: "이전에 입력한 프로필 이미지 소스 방출")
        self.stubMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            let member = Member(uid: "uid", nickName: nil, icon: .emoji("⛳️"))
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.stubMemberUsecase, router: self.spyRouter)
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
        self.stubMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            let member = Member(uid: "uid", nickName: "nick", icon: .emoji("⛳️"))
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.stubMemberUsecase, router: self.spyRouter)
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
        self.stubMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            let member = Member(uid: "uid", nickName: nil, icon: .emoji("⛳️"))
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.stubMemberUsecase, router: self.spyRouter)
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
        
        self.stubMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            var member = Member(uid: "uid", nickName: "some", icon: .emoji("⛳️"))
            member.introduction = "old"
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.stubMemberUsecase, router: self.spyRouter)
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
        
        self.stubMemberUsecase.register(type: Member.self, key: "fetchCurrentMember") {
            var member = Member(uid: "uid", nickName: "some", icon: nil)
            member.introduction = "old"
            return member
        }
        
        // when
        self.viewModel = .init(usecase: self.stubMemberUsecase, router: self.spyRouter)
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
    
    // 저장시 입력정보랑 같이 저장 -> call test
    
    // 이미지있으면 이미지 저장 + 정보 저장 끝날때까지 대기
    
    // 저장 완료시 토스트 노출하고 화면 닫기
    
    // 저장중에 완료버튼 스피너로 바뀜
    
    // 사진 업로드 실패했으면 프로필은 일단 저장하고 에러 토스트 -> 이미지에 오버레이로 실패 표시
}


extension EditProfileViewModelTests {
    
    class SpyRouter: EditProfileRouting, Stubbable {
        
        
    }
}

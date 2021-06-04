//
//  MakeHoorayViewModelTests.swift
//  HooraySceneTests
//
//  Created by sudo.park on 2021/06/04.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import StubUsecases

@testable import HoorayScene


class MakeHoorayViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubMemberUsecase: StubMemberUsecase!
    var stubUsecase: StubHoorayUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MakeHoorayViewModelImple!
    
    private var me: Member {
        return Member(uid: "uid", nickName: "my nickname", icon: .emoji("😱"))
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubMemberUsecase = .init()
        self.stubUsecase = .init()
        self.spyRouter = .init()
        self.stubMemberUsecase.register(key: "fetchCurrentMember") { self.me }
        self.viewModel = .init(memberUsecase: self.stubMemberUsecase,
                               hoorayPublishUsecase: self.stubUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubMemberUsecase = nil
        self.stubUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


// test setup view

extension MakeHoorayViewModelTests {
    
    func testViewModel_setupWithInitialStates() {
        // given
        let expect = expectation(description: "초기상태와 함께 셋업")
        
        // when
        let imageAndKeyword = Observable.combineLatest(self.viewModel.memberProfileImage,
                                                       self.viewModel.hoorayKeyword)
        let pair = self.waitFirstElement(expect, for: imageAndKeyword)
        
        // then
        XCTAssertNotNil(pair)
    }
    
    func testViewModel_whenRequestChangeMemberProfileImage_routeToEditProfileScene() {
        // given
        let expect = expectation(description: "멤버 사진 변경요청시에 프로필 수정 화면으로 라우팅")
        self.spyRouter.called(key: "openEditProfileScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestChangeMemnerProfileImage()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension MakeHoorayViewModelTests {
    
    // 메세지 입력 여부에 따라 버튼 완료 활성화
    func testViewModel_updatePubliishableState_byMessgeInputs() {
        // given
        let expect = expectation(description: "메세지 입력 여부에 따라 확인버튼 활성화 업데이트")
        expect.expectedFulfillmentCount = 3
        
        // when
        let isEnableFlags = self.waitElements(expect, for: self.viewModel.isPublishable) {
            self.viewModel.enterHooray(message: "some")
            self.viewModel.enterHooray(message: "")
        }
        
        // then
        XCTAssertEqual(isEnableFlags, [false, true, false])
    }
    
    // 태그만 입력했을 경우에는 활성화 안함
    func testViewModel_whenOnlyEnterTagWithMessage_publishable() {
        // given
        let expect = expectation(description: "태그를 입력하여도 후레이 메세지가 입력되어야 후레이 발행 활성화")
        expect.expectedFulfillmentCount = 2
        
        // when
        let isEnableFlags = self.waitElements(expect, for: self.viewModel.isPublishable) {
            self.viewModel.enterHooray(tags: ["first".asHoorayTag])
            self.viewModel.enterHooray(tags: ["second".asHoorayTag])
            self.viewModel.enterHooray(message: "message")
        }
        
        // then
        XCTAssertEqual(isEnableFlags, [false, true])
    }
    
    // 장소 선택시 장소 선택 라우팅
    func testViewModel_whenRequestSelectPlace_routeToPlaceScene() {
        // given
        let expect = expectation(description: "장소선책 요청시에 장소선택화면으로 라우팅")
        
        self.spyRouter.called(key: "presentPlaceSelectScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestSelectPlace()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension MakeHoorayViewModelTests {
    
    class SpyRouter: MakeHoorayRouting, Stubbable {
        
        func openEditProfileScene() -> EditProfileScenePresenter? {
            self.verify(key: "openEditProfileScene")
            return nil
        }
        
        func presentPlaceSelectScene() {
            self.verify(key: "presentPlaceSelectScene")
        }
    }
}


private extension String {
    
    var asHoorayTag: HoorayTag {
        return HoorayTag(identifier: UUID().uuidString, text: self)
    }
}

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
    var stubLocationUsecase: StubUserLocationUsecase!
    var stubUsecase: StubHoorayUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MakeHoorayViewModelImple!
    
    private var me: Member {
        return Member(uid: "uid", nickName: "my nickname", icon: .emoji("😱"))
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubMemberUsecase = .init()
        self.stubLocationUsecase = .init()
        self.stubUsecase = .init()
        self.spyRouter = .init()
        self.stubMemberUsecase.register(key: "fetchCurrentMember") { self.me }
        self.viewModel = .init(memberUsecase: self.stubMemberUsecase,
                               userLocationUsecase: self.stubLocationUsecase,
                               hoorayPublishUsecase: self.stubUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubMemberUsecase = nil
        self.stubLocationUsecase = nil
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
    
    func testViewModel_whenRequestPublsihWithoutPlaceInfo_showConfirmPopup() {
        // given
        let expect = expectation(description: "위치정보 없이 후레이 발급 요청시에 정보선택 유도 알럿 알림")
        
        self.spyRouter.called(key: "askSelectPlaceInfo") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.enterHooray(message: "some")
        self.viewModel.requestPublishNewHooray(with: [])
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_requestPublishHoorayWithoutPlaceInfo() {
        // given
        let expect = expectation(description: "위치정보 없이 새로운 후레이 발급 요청")
        
        self.stubUsecase.register(key: "isAvailToPublish") { Maybe<Void>.just() }
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        
        self.stubUsecase.called(key: "publish:newHooray") { args in
            guard let pair = args as? (NewHoorayForm, NewPlaceForm?),
                  pair.1 == nil else { return }
            expect.fulfill()
        }
        
        // when
        self.viewModel.placeSelected(.alreadyExist("some"))
        self.viewModel.enterHooray(message: "message")
        self.viewModel.requestPublishNewHooray(with: [])
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenUnavailtoPublish_alert() {
        // given
        let expect = expectation(description: "발급 불가능할때 불가능 알림")
        self.stubUsecase.register(key: "isAvailToPublish") {
            Maybe<Void>.error(ApplicationErrors.shouldWaitPublishHooray(until: TimeStamp.now()))
        }
        
        self.spyRouter.called(key: "alertShouldWaitPublishNewHooray") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.placeSelected(.alreadyExist("some"))
        self.viewModel.enterHooray(message: "message")
        self.viewModel.requestPublishNewHooray(with: [])
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenAfterPublishHooray_closeSceneAndEmitNewHoorayEvent() {
        // given
        let expect = expectation(description: "발급 완료시에 화면 닫고 외부로 후레이 전파")
        expect.expectedFulfillmentCount = 2
        
        self.stubUsecase.register(key: "isAvailToPublish") { Maybe<Void>.just() }
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.stubUsecase.register(key: "publish:newHooray") { Maybe<Hooray>.just(.dummy(0)) }
        
        self.spyRouter.called(key: "closeScene") { _ in
            expect.fulfill()
        }
        self.viewModel.publishedNewHooray
            .subscribe(onNext: { _ in
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        // when
        self.viewModel.placeSelected(.alreadyExist("some"))
        self.viewModel.enterHooray(message: "message")
        self.viewModel.requestPublishNewHooray(with: [])
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenPublishing_updatePublishingStatus() {
        // given
        let expect = expectation(description: "발급중에는 발급중 상태 업데이트")
        expect.expectedFulfillmentCount = 2
        
        self.stubUsecase.register(key: "isAvailToPublish") { Maybe<Void>.just() }
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.stubUsecase.register(key: "publish:newHooray") { Maybe<Hooray>.just(.dummy(0)) }
        
        // when
        let isPublishing = self.waitElements(expect, for: self.viewModel.isPublishing) {
            self.viewModel.placeSelected(.alreadyExist("some"))
            self.viewModel.enterHooray(message: "message")
            self.viewModel.requestPublishNewHooray(with: [])
        }
        
        // then
        XCTAssertEqual(isPublishing, [false, true])
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
        
        func askSelectPlaceInfo(_ form: AlertForm) {
            self.verify(key: "askSelectPlaceInfo")
        }
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
        
        func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
            self.verify(key: "alertShouldWaitPublishNewHooray")
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.verify(key: "closeScene")
        }
    }
}

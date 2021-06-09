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
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
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
    
    private func newForm(_ mutate: (NewHoorayForm) -> Void) -> NewHoorayForm {
        let form = NewHoorayForm(publisherID: "some")
        mutate(form)
        return form
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
}

// MARK: - test entering sequence

extension MakeHoorayViewModelTests {
    
    func testViewModel_whenAfterShowUp_routeToEnteringImage() {
        // given
        let expect = expectation(description: "화면 최초에 이미지 선택화면으로 라우팅")
        
        self.spyRouter.called(key: "openEnterHoorayImageScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.showUp()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenUserLocationInfoNotLoaded_notRouteToEnteringImage() {
        // given
        let expect = expectation(description: "유저 마지막 위치 아직 반영 안되었으면 선택화면으로 라우팅 x")
        expect.isInverted = true
        
        let lateLoaded = PublishSubject<LastLocation>()
        
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            return lateLoaded.asObservable()
        }
        self.viewModel = .init(memberUsecase: self.stubMemberUsecase,
                               userLocationUsecase: self.stubLocationUsecase,
                               hoorayPublishUsecase: self.stubUsecase, router: self.spyRouter)
        
        self.spyRouter.called(key: "openEnterHoorayImageScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.showUp()
        lateLoaded.onNext(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    private func stubImageInputResult() -> StubEnterPresenter {
        let stubEnterPresenter = StubEnterPresenter()
        self.spyRouter.register(type: EnteringNewHoorayPresenter.self, key: "openEnterHoorayImageScene") {
            stubEnterPresenter
        }
        return stubEnterPresenter
    }
    
    func testViewModel_whenNewImageSelected_updateImage() {
        // given
        let expect = expectation(description: "이미지 선택 이후에 업데이트")
        expect.expectedFulfillmentCount = 2
        
        let stubImageInput = self.stubImageInputResult()
        
        // when
        let imagePaths = self.waitElements(expect, for: self.viewModel.selectedImagePath) {
            self.viewModel.showUp()
            
            let form = self.newForm{ $0.imagePath = "new" }
            stubImageInput.stubEditedForm.onNext(form)
        }
        
        // then
        XCTAssertEqual(imagePaths, [nil, "new"])
    }
    
    private func stubMessageInputResult() -> StubEnterPresenter {
        let stubEnterPresenter = StubEnterPresenter()
        self.spyRouter.register(type: EnteringNewHoorayPresenter.self, key: "openEnterHoorayMessageScene") {
            stubEnterPresenter
        }
        return stubEnterPresenter
    }
    
    func testViewModel_whenAfterEnterMessageWithKeepEntering_updateMessage() {
        // given
        let expect = expectation(description: "지속적인 입력 플로우에서 메세지 입력 이후에 업데이트")
        expect.expectedFulfillmentCount = 2
        
        let stubImageInput = self.stubImageInputResult()
        let stubMessageInput = self.stubMessageInputResult()
        
        // when
        let messages = self.waitElements(expect, for: self.viewModel.enteredMessage) {
            self.viewModel.showUp()
            
            let form = self.newForm{ $0.imagePath = "some" }
            stubImageInput.stubEditedForm.onNext(form)
            
            form.message = "new"
            stubMessageInput.stubEditedForm.onNext(form)
        }
        
        // then
        XCTAssertEqual(messages, [nil, "new"])
    }
    
    private func stubTagInputResult() -> StubEnterPresenter {
        let stubEnterPresenter = StubEnterPresenter()
        self.spyRouter.register(type: EnteringNewHoorayPresenter.self, key: "openEnterHoorayTagScene") {
            stubEnterPresenter
        }
        return stubEnterPresenter
    }
    
    func testViewModel_whenAfterEnterTagWithKeepEntering_updateTags() {
        // given
        let expect = expectation(description: "지속적인 입력 플로우에서 태그 입력 이후에 업데이트")
        expect.expectedFulfillmentCount = 2
        
        let stubImageInput = self.stubImageInputResult()
        let stubMessageInput = self.stubMessageInputResult()
        let stubTagInput = self.stubTagInputResult()
        
        // when
        let tags = self.waitElements(expect, for: self.viewModel.enteredTags) {
            self.viewModel.showUp()
            
            let form = self.newForm{ $0.imagePath = "some" }
            stubImageInput.stubEditedForm.onNext(form)
            
            form.message = "some"
            stubMessageInput.stubEditedForm.onNext(form)
            
            form.tags = ["new"]
            stubTagInput.stubEditedForm.onNext(form)
        }
        
        // then
        XCTAssertEqual(tags, [[], ["new"]])
    }

    private func stubPlaceInputResult() -> StubEnterPresenter {
        let stubEnterPresenter = StubEnterPresenter()
        self.spyRouter.register(type: EnteringNewHoorayPresenter.self, key: "presentPlaceSelectScene") {
            stubEnterPresenter
        }
        return stubEnterPresenter
    }
    
    func testViewModel_whenAfterEnterPlaceWithKeepEntering_updatePlaceName() {
        // given
        let expect = expectation(description: "지속적인 입력 플로우에서 태그 입력 이후에 업데이트")
        expect.expectedFulfillmentCount = 2
        
        let stubImageInput = self.stubImageInputResult()
        let stubMessageInput = self.stubMessageInputResult()
        let stubTagInput = self.stubTagInputResult()
        let stubPlaceInput = self.stubPlaceInputResult()
        
        // when
        let placeNames = self.waitElements(expect, for: self.viewModel.selectedPlaceName) {
            self.viewModel.showUp()
            
            let form = self.newForm{ $0.imagePath = "some" }
            stubImageInput.stubEditedForm.onNext(form)
            
            form.message = "some"
            stubMessageInput.stubEditedForm.onNext(form)
            
            form.tags = ["some"]
            stubTagInput.stubEditedForm.onNext(form)
            
            form.placeID = "pid"
            form.placeName = "new"
            stubPlaceInput.stubEditedForm.onNext(form)
        }
        
        // then
        XCTAssertEqual(placeNames, [nil, "new"])
    }
    
    private func waitForAllEnteted() {
        let expect = expectation(description: "지속적인 입력 플로우에서 태그 입력 이후에 업데이트")
        expect.expectedFulfillmentCount = 2
        
        let stubImageInput = self.stubImageInputResult()
        let stubMessageInput = self.stubMessageInputResult()
        let stubTagInput = self.stubTagInputResult()
        let stubPlaceInput = self.stubPlaceInputResult()
        
        // when
        let _ = self.waitElements(expect, for: self.viewModel.selectedPlaceName) {
            self.viewModel.showUp()
            
            let form = self.newForm{ $0.imagePath = "some" }
            stubImageInput.stubEditedForm.onNext(form)
            
            form.message = "some"
            stubMessageInput.stubEditedForm.onNext(form)
            
            form.tags = ["some"]
            stubTagInput.stubEditedForm.onNext(form)
            
            form.placeID = "pid"
            form.placeName = "new"
            stubPlaceInput.stubEditedForm.onNext(form)
        }
    }
}


// MARK: - test edit input

extension MakeHoorayViewModelTests {
    
    func testViewModel_whenAfterEditImage_notContinueNextEntering() {
        // given
        let expect = expectation(description: "사진정보 입력 이후에 자동으로 다음스탭으로 안넘어감")
        expect.fulfill()
        
        let stubImageInput = self.stubImageInputResult()
        
        self.spyRouter.called(key: "openEnterHoorayMessageScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestEnterImage()
        stubImageInput.stubEditedForm.onNext(self.newForm{ _ in })
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


// MARK: - publish hooray

extension MakeHoorayViewModelTests {
    
    
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
        self.waitForAllEnteted()
        self.viewModel.requestPublishNewHooray()

        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenAfterPublishHooray_closeSceneAndEmitNewHoorayEvent() {
        // given
        let expect = expectation(description: "발급 완료시에 화면 닫고 외부로 후레이 전파")
        expect.expectedFulfillmentCount = 2

        self.stubUsecase.register(key: "isAvailToPublish") { Maybe<Void>.just() }
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
        self.waitForAllEnteted()
        self.viewModel.requestPublishNewHooray()

        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenPublishing_updatePublishingStatus() {
        // given
        let expect = expectation(description: "발급중에는 발급중 상태 업데이트")
        expect.expectedFulfillmentCount = 3
        self.waitForAllEnteted()

        self.stubUsecase.register(key: "isAvailToPublish") { Maybe<Void>.just() }
        self.stubUsecase.register(key: "publish:newHooray") { Maybe<Hooray>.just(.dummy(0)) }

        // when
        let isPublishing = self.waitElements(expect, for: self.viewModel.isPublishing) {
            self.viewModel.requestPublishNewHooray()
        }

        // then
        XCTAssertEqual(isPublishing, [false, true, false])
    }
}


extension MakeHoorayViewModelTests {
    
    class SpyRouter: MakeHoorayRouting, Stubbable {
        
        func openEnterHoorayImageScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
            self.verify(key: "openEnterHoorayImageScene")
            return self.resolve(EnteringNewHoorayPresenter.self, key: "openEnterHoorayImageScene")
        }
        
        func openEnterHoorayMessageScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
            self.verify(key: "openEnterHoorayMessageScene")
            return self.resolve(EnteringNewHoorayPresenter.self, key: "openEnterHoorayMessageScene")
        }
        
        func openEnterHoorayTagScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
            return self.resolve(EnteringNewHoorayPresenter.self, key: "openEnterHoorayTagScene")
        }
        
        func presentPlaceSelectScene(_ form: NewHoorayForm) -> EnteringNewHoorayPresenter? {
            return self.resolve(EnteringNewHoorayPresenter.self, key: "presentPlaceSelectScene")
        }
        
        func openEditProfileScene() -> EditProfileScenePresenter? {
            self.verify(key: "openEditProfileScene")
            return nil
        }
        
        func alertError(_ error: Error) {
            self.verify(key: "alertError")
        }
        
        func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
            self.verify(key: "alertShouldWaitPublishNewHooray")
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.verify(key: "closeScene")
            completed?()
        }
    }
    
    class StubEnterPresenter: EnteringNewHoorayPresenter {
        let stubEditedForm = PublishSubject<NewHoorayForm>()
        var goNextStepWithForm: Observable<NewHoorayForm> {
            return stubEditedForm
        }
    }
}

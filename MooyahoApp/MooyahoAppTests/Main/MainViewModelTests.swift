//
//  MainViewModelTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import MemberScenes
import UsecaseDoubles
import UnitTestHelpKit

@testable import MooyahoApp


class MainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockMemberUsecase: MockMemberUsecase!
    var stubReadLinkAddSuggestUsecase: StubReadLinkAddSuggestUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockMemberUsecase = .init()
        self.spyRouter = .init()
        
        let fakeUsecase = FakeReadItemOptionUsecase()
        
        self.stubReadLinkAddSuggestUsecase = .init()
        
        self.viewModel = .init(memberUsecase: self.mockMemberUsecase,
                               readItemOptionUsecase: fakeUsecase,
                               addItemSuggestUsecase: self.stubReadLinkAddSuggestUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockMemberUsecase = nil
        self.stubReadLinkAddSuggestUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension MainViewModelTests {
    
    func testViewModel_updateMemberProfileImage() {
        // given
        let expect = expectation(description: "멤버 프로필 섬네일 업데이트")
        expect.expectedFulfillmentCount = 2
        
        // when
        let profileImages = self.waitElements(expect, for: self.viewModel.currentMemberProfileImage) {
            var newMember = Member(uid: "some")
            newMember.icon = .emoji("😱")
            self.mockMemberUsecase.currentMemberSubject.onNext(newMember)
        }
        
        // then
        XCTAssertEqual(profileImages.count, 2)
    }
    
    func testViewMdoel_whenRequestOpenSlideMenuWithoutSignIn_requestSignIn() {
        // given
        self.mockMemberUsecase.currentMemberSubject.onNext(nil)
        
        // when
        self.viewModel.requestOpenSlideMenu()
        
        // then
        XCTAssertEqual(self.spyRouter.didSignInRequested, true)
    }
    
    func testViewMdoel_whenRequestOpenSlideMenuWithSignIn_openSlideMenu() {
        // given
        self.mockMemberUsecase.currentMemberSubject.onNext(Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        self.viewModel.requestOpenSlideMenu()
        
        // then
        XCTAssertEqual(self.spyRouter.didSlideMenuOpen, true)
    }
    
    func testViewModel_whenAfterSignIn_replaceReadCollectionMainAndStartMigration() {
        // given
        self.mockMemberUsecase.currentMemberSubject.onNext(nil)
        
        // when
        self.viewModel.requestOpenSlideMenu()
        self.viewModel.signIn(didCompleted: Member(uid: "some", nickName: nil, icon: nil))
        
        // then
        XCTAssertEqual(self.spyRouter.didReadCollectionMainReplaced, true)
        XCTAssertEqual(self.spyRouter.didPresentMigrationScene, true)
    }
}

extension MainViewModelTests {
    
    func testViewModel_addCollectionMainSceneAsSubScene() {
        // given
        let expect = expectation(description: "collection main 화면 서브신으로 추가")
        
        self.spyRouter.called(key: "addReadCollectionScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.setupSubScenes()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenAddNewItemCalled_sendMessageToReadCollectionMainSceneInput() {
        // given
        
        // when
        self.viewModel.setupSubScenes()
        self.viewModel.requestAddNewItem()
        
        // then
        XCTAssertEqual(self.spyRouter.didAskNewItemType, true)
    }
}


extension MainViewModelTests {
    
    func testViewModel_updateIsShrinkMode() {
        // given
        let expect = expectation(description: "isShrink mode 업데이트")
        expect.expectedFulfillmentCount = 3
        
        // when
        let isShrinkMode = self.waitElements(expect, for: self.viewModel.isReadItemShrinkModeOn) {
            self.viewModel.toggleIsReadItemShrinkMode()
            self.viewModel.toggleIsReadItemShrinkMode()
        }
        
        // then
        XCTAssertEqual(isShrinkMode, [false, true, false])
    }
    
    func testViewModel_whenSuggestAddItemByURLExists_showSuggesting() {
        // given
        let expect = expectation(description: "아이템 추가 서제스트 아이템이 존재하는 경우 서제스트 노출")
        self.stubReadLinkAddSuggestUsecase.url = "https://www.naver.com"
        
        // when
        let suggestURL = self.waitFirstElement(expect, for: viewModel.showAddItemInUsingURLInClipBoard) {
            self.viewModel.checkHasSomeSuggestAddItem()
        }
        
        // then
        XCTAssertNotNil(suggestURL)
    }
}


extension MainViewModelTests {
    
    class SpyRouter: MainRouting, Mocking {
        
        var spyCollectionMainSceneInput: SpyReadCollectionMainInput?
        
        var didSignInRequested = false
        func presentSignInScene() {
            self.didSignInRequested = true
        }
        
        func addReadCollectionScene() -> ReadCollectionMainSceneInteractable? {
            self.verify(key: "addReadCollectionScene")
            return spyCollectionMainSceneInput
        }
        
        var didReadCollectionMainReplaced: Bool = false
        func replaceReadCollectionScene() -> ReadCollectionMainSceneInteractable? {
            self.didReadCollectionMainReplaced = true
            return self.spyCollectionMainSceneInput
        }
        
        var didPresentMigrationScene = false
        func presentUserDataMigrationScene(_ userID: String) {
            self.didPresentMigrationScene = true
        }
        
        var didSlideMenuOpen = false
        func openSlideMenu() {
            self.didSlideMenuOpen = true
        }
        
        func presentEditProfileScene() -> EditProfileScenePresenter? {
            self.verify(key: "presentEditProfileScene")
            return nil
        }
        
        func alertForConfirm(_ form: AlertForm) {
            self.verify(key: "alertForConfirm")
        }
        
        func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
            self.verify(key: "alertShouldWaitPublishNewHooray")
        }
        
        var didAskNewItemType = false
        func askAddNewitemType(_ completed: @escaping (Bool) -> Void) {
            self.didAskNewItemType = true
        }
    }
    
    class SpyNearbySceneInteractor: NearbySceneInteractor, Mocking {
        
        func moveMapCameraToCurrentUserPosition() {
            self.verify(key: "moveMapCameraToCurrentUserPosition")
        }
    }
    
    class SpyReadCollectionMainInput: ReadCollectionMainSceneInteractable  {
        
        func addNewCollectionItem() {
            
        }
        
        func addNewReadLinkItem() {
            
        }
        
        func addNewReaedLinkItem(with url: String) {
            
        }
    }
    
    class FakeReadItemOptionUsecase: StubReadItemUsecase {
        
        private let fakeIsShrinkModeOn = BehaviorSubject<Bool>(value: false)
        override var isShrinkModeOn: Observable<Bool> {
            return fakeIsShrinkModeOn.asObservable()
        }
        
        override func updateLatestIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
            self.fakeIsShrinkModeOn.onNext(newvalue)
            return .just()
        }
    }
}

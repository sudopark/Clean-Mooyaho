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
    var stubShareUsecase: StubShareItemUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockMemberUsecase = .init()
        self.spyRouter = .init()
        
        let fakeUsecase = FakeReadItemOptionUsecase()
        
        self.stubReadLinkAddSuggestUsecase = .init()
        
        self.stubShareUsecase = StubShareItemUsecase()
        self.stubShareUsecase.scenario.mySharingCollectionIDs = [[]]
        
        self.viewModel = .init(memberUsecase: self.mockMemberUsecase,
                               readItemOptionUsecase: fakeUsecase,
                               addItemSuggestUsecase: self.stubReadLinkAddSuggestUsecase,
                               shareCollectionUsecase: self.stubShareUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockMemberUsecase = nil
        self.stubReadLinkAddSuggestUsecase = nil
        self.stubShareUsecase = nil
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
    
    func testViewMdoel_whenRequestOpenSlideMenu_openSlideMenu() {
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


// MARK: - test share

extension MainViewModelTests {
    
    func testViewModel_whenMyCollectionRoot_notSharable() {
        // given
        let expect = expectation(description: "낵 콜렉션 루트일때는 공유 불가")
        
        // when
        let status = self.waitFirstElement(expect, for: viewModel.shareStatus) {
            self.stubShareUsecase.refreshMySharingColletionIDs()
            self.viewModel.readCollection(didChange: .myCollections)
            self.viewModel.readCollection(didShowMy: nil)
        }
        
        // then
        XCTAssertEqual(status, .unavail)
    }
    
    func testViewModel_whenShareCompleted_showShareActionSheet() {
        // given
        self.stubShareUsecase.refreshMySharingColletionIDs()
        self.viewModel.readCollection(didChange: .myCollections)
        self.viewModel.readCollection(didShowMy: "some")
        
        // when
        self.viewModel.toggleShareStatus()
        
        // then
        XCTAssertNotNil(self.spyRouter.didSharedURL)
    }
    
    func testViewmOdel_whenShareFail_alertErorr() {
        // given
        self.stubShareUsecase.refreshMySharingColletionIDs()
        self.viewModel.readCollection(didChange: .myCollections)
        self.viewModel.readCollection(didShowMy: "some")
        
        // when
        self.stubShareUsecase.scenario.shareCollectionResult = .failure(ApplicationErrors.invalid)
        self.viewModel.toggleShareStatus()
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertError, true)
    }
    
    func testViewModel_toggleSharingCollection_status() {
        // given
        let expect = expectation(description: "콜렉션 쉐어하고 공유하는 아이템 목록 업데이트됨")
        expect.expectedFulfillmentCount = 2
        self.stubShareUsecase.refreshMySharingColletionIDs()
        self.viewModel.readCollection(didChange: .myCollections)
        self.viewModel.readCollection(didShowMy: "some")
        
        // when
        let status = self.waitElements(expect, for: viewModel.shareStatus) {
            self.viewModel.toggleShareStatus()
        }
        
        // then
        XCTAssertEqual(status, [.activable, .activated])
    }
    
    func testViewModel_whenSharingCollection_showCollectionInfo() {
        // given
        self.stubShareUsecase.refreshMySharingColletionIDs()
        self.viewModel.readCollection(didChange: .myCollections)
        self.viewModel.readCollection(didShowMy: "some")
        self.viewModel.toggleShareStatus()
        
        // when
        self.viewModel.toggleShareStatus()
        
        // then
        XCTAssertNotNil(self.spyRouter.didShowSharingCollectionInfo)
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
        
        func presentEditProfileScene() {
            self.verify(key: "presentEditProfileScene")
        }
        
        func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
            self.verify(key: "alertShouldWaitPublishNewHooray")
        }
        
        var didAskNewItemType = false
        func askAddNewitemType(_ completed: @escaping (Bool) -> Void) {
            self.didAskNewItemType = true
        }
        
        var didSharedURL: String?
        func presentShareSheet(with url: String) {
            self.didSharedURL = url
        }
        
        var didShowSharingCollectionInfo = false
        func showSharingCollectionInfo(_ collectionID: String) {
            self.didShowSharingCollectionInfo = true
        }
        
        var didAlertError = false
        func alertError(_ error: Error) {
            self.didAlertError = true
        }
    }
    
    class SpyNearbySceneInteractor: NearbySceneInteractor, Mocking {
        
        func moveMapCameraToCurrentUserPosition() {
            self.verify(key: "moveMapCameraToCurrentUserPosition")
        }
    }
    
    class SpyReadCollectionMainInput: ReadCollectionMainSceneInteractable  {
        func switchToSharedCollection(_ collection: SharedReadCollection) { }
        
        var rootType: CollectionRoot { .myCollections }
        
        func addNewCollectionItem() {
            
        }
        
        func addNewReadLinkItem() {
            
        }
        
        func addNewReaedLinkItem(with url: String) {
            
        }
        
        func switchToMyReadCollections() { }
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

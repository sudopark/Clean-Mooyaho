//
//  MainViewModelTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import MemberScenes
import UsecaseDoubles
import UnitTestHelpKit

@testable import Readmind


class MainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockAUthUsecase: MockAuthUsecase!
    var mockMemberUsecase: MockMemberUsecase!
    var stubReadLinkAddSuggestUsecase: StubReadLinkAddSuggestUsecase!
    var stubShareUsecase: StubShareItemUsecase!
    var fakeOptionUsecase: FakeReadItemOptionUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        
        self.mockAUthUsecase = .init()
        self.mockMemberUsecase = .init()
        self.spyRouter = .init()
        
        self.fakeOptionUsecase = FakeReadItemOptionUsecase()
        
        self.stubReadLinkAddSuggestUsecase = .init()
        
        self.stubShareUsecase = StubShareItemUsecase()
        self.stubShareUsecase.scenario.mySharingCollectionIDs = [[]]
        
        self.viewModel = .init(authUsecase: self.mockAUthUsecase,
                               memberUsecase: self.mockMemberUsecase,
                               readItemOptionUsecase: self.fakeOptionUsecase,
                               addItemSuggestUsecase: self.stubReadLinkAddSuggestUsecase,
                               shareCollectionUsecase: self.stubShareUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockAUthUsecase = nil
        self.mockMemberUsecase = nil
        self.stubReadLinkAddSuggestUsecase = nil
        self.fakeOptionUsecase = nil
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
        self.mockAUthUsecase.usersignInStatusMocking.onNext(.signIn(.init(userID: "some"), isDeactivated: false))
        
        // then
        XCTAssertEqual(self.spyRouter.didReadCollectionMainReplaced, true)
        XCTAssertEqual(self.spyRouter.didPresentMigrationScene, true)
    }
    
    func testViewModel_whenAfterSignInAndDeactivatedMember_replaceReadCollectionAndPresentActivateAccountScene() {
        // given
        self.mockMemberUsecase.currentMemberSubject.onNext(nil)
        
        // when
        self.viewModel.requestOpenSlideMenu()
        self.mockAUthUsecase.usersignInStatusMocking.onNext(.signIn(.init(userID: "some"), isDeactivated: true))
        
        // then
        XCTAssertEqual(self.spyRouter.didReadCollectionMainReplaced, true)
        XCTAssertEqual(self.spyRouter.didShowActivateAccount, true)
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
    
    func testViewModel_whenAddItemGuideNotShownBefore_showGuide() {
        // given
        // when
        let needShow = self.viewModel.isNeedShowAddItemGuide()
        // then
        XCTAssertEqual(needShow, true)
    }
    
    func testViewModel_whenAddItemGuideShownBefore_notShowGuide() {
        // given
        self.fakeOptionUsecase.scenario.isAddIttemGuideEverShown = true
        // when
        let needShow = self.viewModel.isNeedShowAddItemGuide()
        // then
        XCTAssertEqual(needShow, false)
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
    
    func testViewModel_whenShareFailWithSignInNeedError_showSignInScene() {
        // given
        self.stubShareUsecase.refreshMySharingColletionIDs()
        self.viewModel.readCollection(didChange: .myCollections)
        self.viewModel.readCollection(didShowMy: "some")
        
        // when
        self.stubShareUsecase.scenario.shareCollectionResult = .failure(ApplicationErrors.sigInNeed)
        self.viewModel.toggleShareStatus()
        
        // then
        XCTAssertEqual(self.spyRouter.didSignInRequested, true)
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
    
    func testViewModel_whenShowSharedCollection_unavailToAddItem() {
        // given
        let expect = expectation(description: "공유받은 아이템 조회시에는 아이템 추가 불가")
        expect.expectedFulfillmentCount = 3
        
        // when
        let isAvails = self.waitElements(expect, for: viewModel.isAvailToAddItem) {
            self.viewModel.readCollection(didChange: .sharedCollection(.dummy(0)))
            self.viewModel.readCollection(didChange: .myCollections)
        }
        
        // then
        XCTAssertEqual(isAvails, [true, false, true])
    }
    
    func testViewModel_whenShowSharedCollection_provideShareOwnerInfo() {
        // given
        let expect = expectation(description: "공유받은 콜렉션 조회시에 공유자 정보 제공")
        expect.expectedFulfillmentCount = 2
        let dummy = SharedReadCollection.dummy(0) |> \.ownerID .~ "owner"
        self.mockMemberUsecase.register(key: "members:for") {
            return Observable<[String: Member]>.just(["owner": Member(uid: "owner", nickName: nil, icon: nil)])
        }
        
        // when
        let infos = self.waitElements(expect, for: self.viewModel.currentSharedCollectionOwnerInfo) {
            self.viewModel.readCollection(didChange: .sharedCollection(dummy))
        }
        
        // then
        XCTAssertNil(infos.first ?? nil)
        XCTAssertNotNil(infos.last ?? nil)
    }
    
    func testViiewModel_returnToMyReadCollection() {
        // given
        let spyMainSceneInteractor = SpyReadCollectionMainInteractor()
        self.spyRouter.spyCollectionMainSceneInput = spyMainSceneInteractor
        self.viewModel.setupSubScenes()
        self.viewModel.readCollection(didChange: .sharedCollection(.dummy(0)))
        
        // when
        self.viewModel.returnToMyReadCollections()
        let form = self.spyRouter.didAlertConfirmForm
        form?.confirmed?()
        
        // then
        XCTAssertEqual(spyMainSceneInteractor.didSwitchToMyCollectionRequested, true)
    }
    
    func testViewModel_showSharedCollectionInfo() {
        // given
        self.viewModel.setupSubScenes()
        self.viewModel.readCollection(didChange: .sharedCollection(.dummy(0)))
        
        // when
        self.viewModel.showSharedCollectionDetail()
        
        // then
        XCTAssertNotNil(self.spyRouter.didShowSharedCollectionDialog)
    }
    
    func testViewModel_switchToMyReadCollection_afterRemoveSharedCollectionFromList() {
        // given
        let spyMainSceneInteractor = SpyReadCollectionMainInteractor()
        self.spyRouter.spyCollectionMainSceneInput = spyMainSceneInteractor
        self.viewModel.setupSubScenes()
        self.viewModel.readCollection(didChange: .sharedCollection(.dummy(0)))
        
        // when
        self.viewModel.sharedCollectionDidRemoved("some")
        
        // then
        XCTAssertEqual(spyMainSceneInteractor.didSwitchToMyCollectionRequested, true)
    }
}

extension MainViewModelTests {
    
    func testViewModel_startSearch() {
        // given
        // when
        self.viewModel.didUpdateBottomSearchAreaShowing(isShow: true)
        self.viewModel.didUpdateSearchText("some")
        self.viewModel.didRequestSearch(with: "search")
        
        // then
        XCTAssertEqual(self.spyRouter.spySearchInteractor?.didSuggestRequested, true)
        XCTAssertEqual(self.spyRouter.spySearchInteractor?.didSearchRequested, true)
    }
    
    func testViewModel_finishSearch() {
        // given
        // when
        self.viewModel.didUpdateBottomSearchAreaShowing(isShow: true)
        self.viewModel.didUpdateSearchText("some")
        self.viewModel.didRequestSearch(with: "search")
        self.viewModel.didUpdateBottomSearchAreaShowing(isShow: false)
        
        // then
        XCTAssertNil(self.spyRouter.spySearchInteractor)
    }
    
    func testViewMdoel_finishSearch_fromOutside() {
        // given
        let expect = expectation(description: "외부에서 들어온 검색종료 요청 처리")
        expect.expectedFulfillmentCount = 2
        self.viewModel.didUpdateBottomSearchAreaShowing(isShow: true)
        self.viewModel.didUpdateSearchText("some")
        
        self.viewModel.isSearchFinished
            .subscribe(onNext: {
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        // when
        self.viewModel.finishIntegratedSearch {
            expect.fulfill()
        }
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension MainViewModelTests {
    
    class SpyRouter: MainRouting, Mocking {
        
        var spyCollectionMainSceneInput: SpyReadCollectionMainInteractor?
        var spySearchInteractor: SpyIntegratedSearchInteractor?
        
        var didSignInRequested = false
        func presentSignInScene() {
            self.didSignInRequested = true
        }
        
        func addReadCollectionScene() -> ReadCollectionMainSceneInteractable? {
            self.verify(key: "addReadCollectionScene")
            return spyCollectionMainSceneInput
        }
        
        func addSuggestReadScene() -> SuggestReadSceneInteractable? {
            return nil
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
        
        var didShowActivateAccount: Bool?
        func presentActivateAccountScene(_ userID: String) {
            self.didShowActivateAccount = true
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
        
        var didShowSharedCollection: SharedReadCollection?
        func showSharedCollection(_ collection: SharedReadCollection) {
            self.didShowSharedCollection = collection
        }
        
        var didShowSharedCollectionDialog = false
        func showSharedCollectionDialog(for collection: SharedReadCollection) {
            self.didShowSharedCollectionDialog = true
        }
        
        var didAlertConfirmForm: AlertForm?
        func alertForConfirm(_ form: AlertForm) {
            self.didAlertConfirmForm = form
        }
        
        func addSaerchScene() -> IntegratedSearchSceneInteractable? {
            self.spySearchInteractor = SpyIntegratedSearchInteractor()
            return self.spySearchInteractor
        }
        
        func removeSearchScene() {
            self.spySearchInteractor = nil
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            completed?()
        }
        
        var didShowRemindDetail: Bool?
        func showRemindDetail(_ itemID: String) {
            self.didShowRemindDetail = true
        }
    }
    
    class SpyNearbySceneInteractor: NearbySceneInteractor, Mocking {
        
        func moveMapCameraToCurrentUserPosition() {
            self.verify(key: "moveMapCameraToCurrentUserPosition")
        }
    }
    
    class SpyReadCollectionMainInteractor: ReadCollectionMainSceneInteractable  {
        
        func switchToSharedCollection(_ collection: SharedReadCollection) { }
        
        var rootType: CollectionRoot { .myCollections }
        
        func addNewCollectionItem() {
            
        }
        
        func addNewReadLinkItem() {
            
        }
        
        func addNewReaedLinkItem(with url: String) {
            
        }
        
        var didSwitchToMyCollectionRequested = false
        func switchToMyReadCollections() {
            self.didSwitchToMyCollectionRequested = true
        }
        
        var didJumpRequested: Bool?
        func jumpToCollection(_ collectionID: String?) {
            self.didJumpRequested = true
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
    
    class SpyIntegratedSearchInteractor: IntegratedSearchSceneInteractable {
        
        var didSuggestRequested: Bool?
        func requestSuggest(with text: String) {
            self.didSuggestRequested = true
        }
        
        var didSearchRequested: Bool?
        func requestSearchItems(with text: String) {
            self.didSearchRequested = true
        }
        
        func suggestQuery(didSelect searchQuery: String) { }
        
        func innerWebView(reqeustJumpTo collectionID: String?) { }
    }
}

//
//  ReadItemUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit

import Domain

class ReadItemUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRepository: SpyRepository!
    private var spyStore: SharedDataStoreService!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private var myID: String { "me" }
    
    private func authProvider(_ signedIn: Bool = true) -> AuthInfoProvider {
        let sharedStore = SharedDataStoreServiceImple()
        let auth = Auth(userID: self.myID)
        sharedStore.updateAuth(auth)
        if signedIn {
            let member = Member(uid: auth.userID, nickName: "n", icon: nil)
            sharedStore.save(Member.self, key: SharedDataKeys.currentMember, member)
        }
        return sharedStore
    }
    
    private func makeUsecase(signedIn: Bool = true,
                             shouldfailLoadMyCollections: Bool = false,
                             shouldFailLoadCollection: Bool = false,
                             isShrinkModeOn: Bool = true,
                             sortOrder: ReadCollectionItemSortOrder? = .default,
                             customSortOrder: [String] = []) -> ReadItemUsecase {
        
        var repositoryScenario = StubReadItemRepository.Scenario()
        shouldfailLoadMyCollections.then {
            repositoryScenario.myItems = .failure(ApplicationErrors.invalid)
        }
        shouldFailLoadCollection.then {
            repositoryScenario.localCollection = .failure(ApplicationErrors.invalid)
        }
        
        let repositoryStub = SpyRepository(scenario: repositoryScenario)
        self.spyRepository = repositoryStub
        
        let optionsScenario = StubReadItemOptionsRepository.Scenario()
            |> \.isShrinkMode .~ .success(isShrinkModeOn)
            |> \.sortOrder .~ .success(sortOrder)
            |> \.customOrder .~ .success(customSortOrder)
        let optionRepository = StubReadItemOptionsRepository(scenario: optionsScenario)
        
        let store = SharedDataStoreServiceImple()
        self.spyStore = store
        
        return ReadItemUsecaseImple(itemsRespoitory: repositoryStub,
                                    optionsRespository: optionRepository,
                                    authInfoProvider: self.authProvider(signedIn),
                                    sharedStoreService: store)
    }
}


// MARK: - tests load

extension ReadItemUsecaseTests {
    
    func testUsecase_loadMyItemsWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 내 아이템 조회")
        let usecase = self.makeUsecase(signedIn: false)
        
        // when
        let items = self.waitFirstElement(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertEqual(items?.count, 11)
    }
    
    func testUsecase_loadMyItemsFailWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 내 아이켐 조회 실패")
        let usecase = self.makeUsecase(signedIn: false, shouldfailLoadMyCollections: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_loadMyItemsWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 내 아이템 조회")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let itemLists = self.waitElements(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertEqual(itemLists.count, 2)
    }
    
    func testUsecase_loadCollectionWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 콜렉션 로드")
        let usecase = self.makeUsecase(signedIn: false)
        
        // when
        let items = self.waitFirstElement(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertNotNil(items)
    }
    
    // load collection + 로그아웃 상태 -> 캐시에 저장된거 불러몸, 없으면 에러
    func testUsecase_loadCollectionItemsFailWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 콜렉션 로드 실패")
        let usecase = self.makeUsecase(signedIn: false, shouldFailLoadCollection: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertNotNil(error)
    }
    
    // load collection + 로그인 상태 -> 캐시에 저장된거 + 리모트에서 불러옴
    func testUsecase_loadCollectionWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 콜렉션 로드")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let itemLists = self.waitElements(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertEqual(itemLists.count, 2)
    }
    
    // load collection + 로그인 상태 -> 캐시와 리모트에 둘다 없으면 에러
    func testUsecase_loadCollectionFailWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 콜렉션 로드시 로컬 로드 실패")
        let usecase = self.makeUsecase(signedIn: true,
                                       shouldFailLoadCollection: true)
        
        // when
        let error = self.waitError(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertNotNil(error)
    }
}


extension ReadItemUsecaseTests {
    
    // update cool
    func testUsecase_updateCollection() {
        // given
        let expect = expectation(description: "콜렉션 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let update = usecase.updateCollection(.dummy(0))
        let result: Void? = self.waitFirstElement(expect, for: update.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    
    func testUsecase_whenUpdateCollectionWithSignedIn_setOwnerID() {
        // given
        let expect = expectation(description: "로그인 상태에서 콜렉션 저장시에 오너아이디 지정하고 저장")
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let update = usecase.updateCollection(.dummy(0))
        let _ = self.waitFirstElement(expect, for: update.asObservable())
        
        // then
        let collection = self.spyRepository.updatedCollection
        XCTAssertEqual(collection?.ownerID, self.myID)
    }
    
    // 로그인 상태에서 콜렉션 생성
    func testUsecase_makeNewCollection() {
        // given
        let expect = expectation(description: "콜렉션 생성")
        let usecase = self.makeUsecase()
        
        // when
        let make = usecase.makeCollection(.dummy(0), at: "some")
        let result: Void? = self.waitFirstElement(expect, for: make.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_saveLink() {
        // given
        let expect = expectation(description: "아이템 저장")
        let usecase = self.makeUsecase()
        
        // when
        let save = usecase.saveLink(.dummy(0), at: "some")
        let result: Void? = self.waitFirstElement(expect, for: save.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_saveLinkURL() {
        // given
        let expect = expectation(description: "링크 저장")
        let usecase = self.makeUsecase()
        
        // when
        let save = usecase.saveLink("link_url", at: "some")
        let result: Void? = self.waitFirstElement(expect, for: save.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenUpdateLinkWithSignedIn_updateOwnerID() {
        // given
        let expect = expectation(description: "로그인상태에서 링크 업데이트시에 오너아이디 세팅")
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let updating = usecase.updateLink(.init(link: "some"))
        let _ = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        let link = self.spyRepository.updatedLink
        XCTAssertEqual(link?.ownerID, self.myID)
    }
}

extension ReadItemUsecaseTests {
    
    func testUsecase_loadShrinkModeOn() {
        // given
        let expect = expectation(description: "shrink mode 패치")
        let usecase = self.makeUsecase()
        
        // when
        let loading = usecase.loadShrinkModeIsOnOption()
        let isOn = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(isOn, true)
    }
    
    func testUsecase_whenShrinkModeLoadbefore_useThatValue() {
        // given
        let expect = expectation(description: "이전에 로드한 플래그값이 있으면 이용")
        let usecase = self.makeUsecase(isShrinkModeOn: true)
        
        // when
        let loadAndReload = usecase.loadShrinkModeIsOnOption()
            .flatMap{ _ in usecase.loadShrinkModeIsOnOption() }
        let isOn = self.waitFirstElement(expect, for: loadAndReload.asObservable())
        
        // then
        XCTAssertEqual(isOn, true)
    }
    
    func testUsecase_updateShrinkModeIsOn() {
        // given
        let expect = expectation(description: "shrink mode 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let updating = usecase.updateIsShrinkModeIsOn(false)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenAfterUpdateIsShrink_updateOnStore() {
        // given
        let expect = expectation(description: "shrink mode 업데이트 이후에 데이터스토어에도 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let updated = self.spyStore.observe(Bool.self, key: SharedDataKeys.readItemShrinkIsOn.rawValue)
        let isOn = self.waitFirstElement(expect, for: updated) {
            usecase.updateIsShrinkModeIsOn(true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(isOn, true)
    }
}

extension ReadItemUsecaseTests {
    
    func testUsecase_loadSortOrder() {
        // given
        let expect = expectation(description: "sort order 로드")
        let usecase = self.makeUsecase(sortOrder: .byPriority(false))
        
        // when
        let loading = usecase.loadLatestSortOption(for: "some")
        let order = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(order, .byPriority(false))
    }
    
    func testUsecase_whenPreloadedSortOrderExists_useIt() {
        // given
        let expect = expectation(description: "미리 로드된 정렬옵션 존재시에 해당값 사용")
        let usecase = self.makeUsecase(sortOrder: .byCustomOrder)
        
        // when
        let loadAndReload = usecase.loadLatestSortOption(for: "some")
            .flatMap{ _ in usecase.loadLatestSortOption(for: "some") }
        let order = self.waitFirstElement(expect, for: loadAndReload.asObservable())
        
        // then
        XCTAssertEqual(order, .byCustomOrder)
    }
    
    func testUsecase_whenSortOrderNotExistsForCollection_useLatestUsedSortOrder() {
        // given
        let expect = expectation(description: "해당 콜렉션을 위한 정렬옵션 존재 안하는 경우 마지막으로 이용했던값 이용")
        let usecase = self.makeUsecase(sortOrder: nil)
        self.spyStore.save(ReadCollectionItemSortOrder.self, key: .latestReadItemSortOption, .byPriority(true))
        
        // when
        let loading = usecase.loadLatestSortOption(for: "some")
        let order = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(order, .byPriority(true))
    }
    
    func testUsecase_whenSortOrderAndLatestSortOrderNotExistsForCollection_useDefaultValue() {
        // given
        let expect = expectation(description: "해당 콜렉션을 위한 정렬옵션과 마지막 사용 정렬값이 존재 안하는 경우 디폴튿값 이룔")
        let usecase = self.makeUsecase(sortOrder: nil)
        
        // when
        let loading = usecase.loadLatestSortOption(for: "some")
        let order = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(order, .default)
    }
    
    func testUsecase_updateSortOrder() {
        // given
        let expect = expectation(description: "sort order 업데이트시에 로컬이랑 store 둘다 업데이트")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let updatedOnStore = self.spyStore
            .observe([String: ReadCollectionItemSortOrder].self, key: SharedDataKeys.readItemSortOptionMap.rawValue)
            .map{ $0?["some"] }.filter{ $0 == .byCustomOrder }.map{ _ in }
        let updateOnLocal = usecase.updateSortOption(for: "some", to: .byCustomOrder).asObservable()
        let updatings = Observable.merge(updatedOnStore, updateOnLocal)
        let isUpdatedBoth: [Void] = self.waitElements(expect, for: updatings)
        
        // then
        XCTAssertEqual(isUpdatedBoth.count, 2)
    }
}

extension ReadItemUsecaseTests {
    
    func testUsecase_loadCustomSortOrder() {
        // given
        let expect = expectation(description: "custom sort order 로드")
        let usecase = self.makeUsecase(customSortOrder: ["c1", "c2"])
        
        // when
        let loading = usecase.loadCustomOrder(for: "some")
        let orders = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(orders, ["c1", "c2"])
    }
    
    func testUsecase_whenPreloadedCustomSortOrderExists_useIt() {
        // given
        let expect = expectation(description: "미리 로드된 custom 정렬 존재시에 해당값 사용")
        let usecase = self.makeUsecase(customSortOrder: ["c1", "c2"])
        
        // when
        let loadAndReload = usecase.loadCustomOrder(for: "some")
            .flatMap{ _ in usecase.loadCustomOrder(for: "some") }
        let orders = self.waitFirstElement(expect, for: loadAndReload.asObservable())
        
        // then
        XCTAssertEqual(orders, ["c1", "c2"])
    }
    
    func testUsecase_updateCustomSortOrder() {
        // given
        let expect = expectation(description: "custom sort order 업데이트시에 로컬이랑 store 둘다 업데이트")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let updatedOnStore = self.spyStore
            .observe([String: [String]].self, key: SharedDataKeys.readItemCustomOrderMap.rawValue)
            .map{ $0?["some"] }.filter{ $0?.isNotEmpty == true }.map{ _ in }
        let updateOnLocal = usecase.updateCustomOrder(for: "some", itemIDs: ["c"]).asObservable()
        let updatings = Observable.merge(updatedOnStore, updateOnLocal)
        let isUpdatedBoth: [Void] = self.waitElements(expect, for: updatings)
        
        // then
        XCTAssertEqual(isUpdatedBoth.count, 2)
    }
}


private extension ReadItemUsecaseTests {
    
    final class SpyRepository: StubReadItemRepository {
        
        var updatedCollection: ReadCollection?
        var updatedLink: ReadLink?
        
        override func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void> {
            self.updatedCollection = collection
            return super.requestUpdateCollection(collection)
        }
        
        override func requestUpdateLink(_ link: ReadLink) -> Maybe<Void> {
            self.updatedLink = link
            return super.requestUpdateLink(link)
        }
    }
}
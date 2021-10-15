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
                             isShrinkModeOn: Bool? = true,
                             sortOrder: ReadCollectionItemSortOrder? = .default,
                             customSortOrder: [String] = []) -> ReadItemUsecase {
        
        var repositoryScenario = StubReadItemRepository.Scenario()
        shouldfailLoadMyCollections.then {
            repositoryScenario.myItems = .failure(ApplicationErrors.invalid)
        }
        shouldFailLoadCollection.then {
            repositoryScenario.collectionItems = .failure(ApplicationErrors.invalid)
        }
        
        let repositoryStub = SpyRepository(scenario: repositoryScenario)
        self.spyRepository = repositoryStub
        
        let previewRepositoryStub = StubLinkPreviewRepository()
        
        let optionsScenario = StubReadItemOptionsRepository.Scenario()
            |> \.isShrinkMode .~ .success(isShrinkModeOn)
            |> \.sortOrder .~ .success(sortOrder)
            |> \.customOrder .~ .success(customSortOrder)
        let optionRepository = StubReadItemOptionsRepository(scenario: optionsScenario)
        
        let store = SharedDataStoreServiceImple()
        self.spyStore = store
        
        return ReadItemUsecaseImple(itemsRespoitory: repositoryStub,
                                    previewRepository: previewRepositoryStub,
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
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let itemLists = self.waitElements(expect, for: usecase.loadMyItems())
        
        // then
        XCTAssertEqual(itemLists.count, 1)
    }
    
    func testUsecase_loadCollectionItemWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그아웃상태에서 콜렉션 item 로드")
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
    func testUsecase_loadCollectionItemsWithSignedIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 콜렉션 items 로드")
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let itemLists = self.waitElements(expect, for: usecase.loadCollectionItems("some"))
        
        // then
        XCTAssertEqual(itemLists.count, 1)
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
    
    func testUsecase_loadCollectionWithoutSignedIn() {
        // given
        let expect = expectation(description: "로그인 안한상태로 콜렉션 로드")
        let usecase = self.makeUsecase(signedIn: false)
        
        // when
        let loading = usecase.loadCollectionInfo("some")
        let collection = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertNotNil(collection)
    }
    
    func testUsecase_loadCollectionWithSignedIn() {
        // given
        let expect = expectation(description: "로그인한 상태에서 콜렉션 로드")
        let usecase = self.makeUsecase(signedIn: true)
        
        // when
        let loading = usecase.loadCollectionInfo("some")
        let collection = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertNotNil(collection)
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
    
    func testUsecase_loadLinkPreview() {
        // given
        let expect = expectation(description: "link preview 로드")
        let usecase = self.makeUsecase()
        
        // when
        let loading = usecase.loadLinkPreview("some")
        let preview = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertNotNil(preview)
    }
    
    func testUsecase_whenPreviewExistsInMemory_loadLinkPreview() {
        // given
        let expect = expectation(description: "link preview shared store에 존재하는경우 로드")
        let previewMap: [String: LinkPreview] = ["some": LinkPreview.dummy(0)]
        let usecase = self.makeUsecase()
        self.spyStore.save([String: LinkPreview].self, key: .readLinkPreviewMap, previewMap)
        
        // when
        let loading = usecase.loadLinkPreview("some")
        let preview = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertNotNil(preview)
    }
}

extension ReadItemUsecaseTests {
    
    func testUsecase_loadShrinkModeOn() {
        // given
        let expect = expectation(description: "shrink mode 패치")
        let usecase = self.makeUsecase()
        
        // when
        let isOn = self.waitFirstElement(expect, for: usecase.isShrinkModeOn)
        
        // then
        XCTAssertEqual(isOn, true)
    }
    
    func testUsecase_whenLoadShrinkModeOnIsNotExists_useDefaultValue() {
        // given
        let expect = expectation(description: "shrink mode 패치시 없으면 디폴트값 이용")
        let usecase = self.makeUsecase(isShrinkModeOn: nil)
        
        // when
        let isOn = self.waitFirstElement(expect, for: usecase.isShrinkModeOn)
        
        // then
        XCTAssertEqual(isOn, false)
    }
    
    func testUsecase_updateShrinkModeIsOn() {
        // given
        let expect = expectation(description: "shrink mode 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let updating = usecase.updateLatestIsShrinkModeIsOn(false)
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
            usecase.updateLatestIsShrinkModeIsOn(true)
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
        let expect = expectation(description: "마지막으로 사용한 sort order 로드")
        let usecase = self.makeUsecase(sortOrder: .byPriority(false))
        
        // when
        let order = self.waitFirstElement(expect, for: usecase.sortOrder)
        
        // then
        XCTAssertEqual(order, .byPriority(false))
    }
    
    func testUsecase_whenLatestSortOrderNotExists_useDefaultValue() {
        // given
        let expect = expectation(description: "마지막 사용 정렬값이 존재 안하는 경우 디폴튿값 이룔")
        let usecase = self.makeUsecase(sortOrder: nil)
        
        // when
        let order = self.waitFirstElement(expect, for: usecase.sortOrder)
        
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
            .observe(ReadCollectionItemSortOrder.self, key: SharedDataKeys.latestReadItemSortOption.rawValue)
            .filter{ $0 == .byCustomOrder }.map{ _ in }
        let updateOnLocal = usecase.updateLatestSortOption(to: .byCustomOrder).asObservable()
        let updatings = Observable.merge(updatedOnStore, updateOnLocal)
        let isUpdatedBoth: [Void] = self.waitElements(expect, for: updatings)
        
        // then
        XCTAssertEqual(isUpdatedBoth.count, 2)
    }
    
    func testUsecase_provideCurrentSortOptionEventStream() {
        // given
        let expect = expectation(description: "현재 설정된 옵션값 이벤트 스트림 제공")
        expect.expectedFulfillmentCount = 2
        
        let usecase = self.makeUsecase()
        
        // when
        let orders = self.waitElements(expect, for: usecase.sortOrder) {
            self.spyStore.save(ReadCollectionItemSortOrder.self, key: .latestReadItemSortOption, .byLastUpdatedAt(true))
        }
        
        // then
        XCTAssertEqual(orders, [.default, .byLastUpdatedAt(true)] )
    }
}

extension ReadItemUsecaseTests {
    
    func testUsecase_loadCustomSortOrder() {
        // given
        let expect = expectation(description: "custom sort order 로드 + 이후 변경된값 인지 가능")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(customSortOrder: ["c1", "c2"])
        
        // when
        let loading = usecase.customOrder(for: "some")
        let orders = self.waitElements(expect, for: loading.asObservable()) {
            self.spyStore.update([String: [String]].self, key: SharedDataKeys.readItemCustomOrderMap.rawValue) {
                return ($0 ?? [:]) |> key("some") .~ ["c1", "c2", "c3"]
            }
        }
        
        // then
        XCTAssertEqual(orders, [["c1", "c2"], ["c1", "c2", "c3"]])
    }
    
    func testUsecase_whenPreloadedCustomSortOrderExists_useIt() {
        // given
        let expect = expectation(description: "미리 로드된 custom 정렬 존재시에 해당값 사용 + 이후 변경된값 인지 가능")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase(customSortOrder: ["c1", "c2"])
        
        // when
        let loadAndReload = usecase.customOrder(for: "some")
            .flatMap{ _ in usecase.customOrder(for: "some") }
        let orders = self.waitElements(expect, for: loadAndReload.asObservable()) {
            self.spyStore.update([String: [String]].self, key: SharedDataKeys.readItemCustomOrderMap.rawValue) {
                return ($0 ?? [:]) |> key("some") .~ ["c1", "c2", "c3"]
            }
        }
        
        // then
        XCTAssertEqual(orders, [["c1", "c2"], ["c1", "c2", "c3"]])
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

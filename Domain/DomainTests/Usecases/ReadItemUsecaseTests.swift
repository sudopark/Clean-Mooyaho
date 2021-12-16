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
    private var mockItemUpdateSubject: PublishSubject<ReadItemUpdateEvent>!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockItemUpdateSubject = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockItemUpdateSubject = nil
    }
    
    var myID: String { "me" }
    
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
    
    func makeUsecase(signedIn: Bool = true,
                     shouldfailLoadMyCollections: Bool = false,
                     shouldFailLoadCollection: Bool = false,
                     isShrinkModeOn: Bool? = true,
                     sortOrder: ReadCollectionItemSortOrder? = .default,
                     collectionMocking: ReadCollection? = nil,
                     customSortOrder: [String] = [],
                     copiedText: String? = nil,
                     isReloadNeed: Bool = true) -> ReadItemUsecaseImple {
        
        var repositoryScenario = StubReadItemRepository.Scenario()
        shouldfailLoadMyCollections.then {
            repositoryScenario.myItems = .failure(ApplicationErrors.invalid)
        }
        shouldFailLoadCollection.then {
            repositoryScenario.collectionItems = .failure(ApplicationErrors.invalid)
        }
        repositoryScenario.ulrAndLinkItemMap = ["some": ReadLink.dummy(0, parent: nil)]
        let repositoryStub = SpyRepository(scenario: repositoryScenario)
        repositoryStub.collectionMocking = collectionMocking
        repositoryStub.reloadNeedMocking = isReloadNeed
        self.spyRepository = repositoryStub
        
        let previewRepositoryStub = StubLinkPreviewRepository()
        
        let optionsScenario = StubReadItemOptionsRepository.Scenario()
            |> \.isShrinkMode .~ .success(isShrinkModeOn)
            |> \.sortOrder .~ .success(sortOrder)
            |> \.customOrder .~ .success(customSortOrder)
        let optionRepository = StubReadItemOptionsRepository(scenario: optionsScenario)
        
        let store = SharedDataStoreServiceImple()
        self.spyStore = store
        
        let clipboardService = StubClipBoardService()
            |> \.copiedString .~ copiedText
        
        return ReadItemUsecaseImple(itemsRespoitory: repositoryStub,
                                    previewRepository: previewRepositoryStub,
                                    optionsRespository: optionRepository,
                                    authInfoProvider: self.authProvider(signedIn),
                                    sharedStoreService: store,
                                    clipBoardService: clipboardService,
                                    readItemUpdateEventPublisher: self.mockItemUpdateSubject,
                                    remindMessagingService: StubReminderMessagingService(),
                                    shareURLScheme: "readminds")
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
    
    func testUsecase_excludeAlreadPassedRemidTime() {
        // given
        let expect1 = expectation(description: "이미 지난 리마인드 타임이 있는 콜렉션 로드")
        let expect2 = expectation(description: "유효한 리마인드 타임이 있는 콜렉션 로드")
    
        let collection1 = ReadCollection.dummy(0, parent: nil) |> \.remindTime .~ (0)
        let collection2 = ReadCollection.dummy(0, parent: nil) |> \.remindTime .~ (.now() + 1000)
        
        let usecase1 = self.makeUsecase(collectionMocking: collection1)
        let usecase2 = self.makeUsecase(collectionMocking: collection2)
        
        // when
        let loading1 = usecase1.loadCollectionInfo(collection1.uid)
        let remindTime1 = self.waitFirstElement(expect1, for: loading1.asObservable()).map { $0.remindTime }
        let loading2 = usecase2.loadCollectionInfo(collection2.uid)
        let remindTime2 = self.waitFirstElement(expect2, for: loading2.asObservable()).map { $0.remindTime }
        
        // then
        XCTAssertEqual(remindTime1 ?? nil, nil)
        XCTAssertEqual(remindTime2, collection2.remindTime)
    }
    
    func testUsecase_loadReadLinkItem() {
        // given
        let expect = expectation(description: "link item 로드")
        let usecase = self.makeUsecase()
        
        // when
        let loading = usecase.loadReadLink("some")
        let link = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(link)
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
    
    func testUsecase_whenAfterUpdateCollection_broadcast() {
        // given
        let expect = expectation(description: "콜렉션 수정 이후 업데이트된 콜렉션 광역 전파")
        let usecase = self.makeUsecase()
        
        // when
        let dummyCollection = ReadCollection.dummy(0)
        let event = self.waitFirstElement(expect, for: usecase.readItemUpdated) {
            usecase.updateCollection(dummyCollection)
                .subscribe().disposed(by: self.disposeBag)
        }
        
        // then
        if case let .updated(item) = event, let collection = item as? ReadCollection {
            XCTAssertEqual(collection.uid, dummyCollection.uid)
        } else {
            XCTFail("이벤트 전파 실패")
        }
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
    
    func testUsecase_whenAfterUpdateLink_broadcast() {
        // given
        let expect = expectation(description: "link item 수정 이후 업데이트된 콜렉션 광역 전파")
        let usecase = self.makeUsecase()
        
        // when
        let dummyLink = ReadLink.dummy(0)
        let event = self.waitFirstElement(expect, for: usecase.readItemUpdated) {
            usecase.updateLink(dummyLink)
                .subscribe().disposed(by: self.disposeBag)
        }
        
        // then
        if case let .updated(item) = event, let link = item as? ReadLink {
            XCTAssertEqual(link.uid, dummyLink.uid)
        } else {
            XCTFail("이벤트 전파 실패")
        }
    }
    
    func testUsecase_updateItemWithParams() {
        // given
        let expect = expectation(description: "파라미터로 아이템 업데이트 요청")
        let usecase = self.makeUsecase()
        
        // when
        let params = ReadItemUpdateParams(item: ReadLink.dummy(9, parent: nil))
            |> \.updatePropertyParams .~ [.remindTime(.now())]
        let updating = usecase.updateItem(params)
        let result: Void? = self.waitFirstElement(expect, for: updating.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUSecase_whenAfterUpdateItemWithParams_broadCast() {
        // given
        let expect = expectation(description: "파라미터로 아이템 수정한 이후에 광역 전파")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        let dummyItem = ReadLink.dummy(0)
        
        // when
        let events = self.waitElements(expect, for: usecase.readItemUpdated) {
            let param1 = ReadItemUpdateParams(item: dummyItem)
                |> \.updatePropertyParams .~ [.remindTime(100)]
            usecase.updateItem(param1).subscribe().disposed(by: self.disposeBag)
            
            let param2 = ReadItemUpdateParams(item: dummyItem |> \.remindTime .~ 100)
                |> \.updatePropertyParams .~ [.remindTime(nil)]
            usecase.updateItem(param2).subscribe().disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(events.map { $0.remindTime }, [100, nil])
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

    func testUsecase_removeItem() {
        // given
        let expect = expectation(description: "아이템 삭제")
        let usecase = self.makeUsecase()
        
        // when
        let removing = usecase.removeItem(ReadCollection.dummy(9, parent: nil))
        let result: Void? = self.waitFirstElement(expect, for: removing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_whenAfterRemoveItem_broadcastRemoved() {
        // given
        let expect = expectation(description: "아이템 삭제 이후에 삭제되었음을 이벤트 전파")
        let usecase = self.makeUsecase()
        let dummy = ReadCollection.dummy(0, parent: 100)
        
        // when
        let eventSource = self.mockItemUpdateSubject ?? .empty()
        let updateEvent = self.waitFirstElement(expect, for: eventSource.asObservable()) {
            usecase.removeItem(dummy)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        if case let .removed(itemID, parent) = updateEvent {
            XCTAssertEqual(itemID, dummy.uid)
            XCTAssertEqual(parent, dummy.parentID)
        } else {
            XCTFail("기대하는 이벤트가 아님")
        }
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


// MARK: - ReadLinkAddSuggestUsecase

extension ReadItemUsecaseTests {
    
    func testUsecase_whenLinkItemExists_checkURLIsExists() {
        // given
        let expect = expectation(description: "url에 해당하는 link item이 추가되어있는지 검사")
        let usecase = self.makeUsecase(copiedText: "https://www.naver.com")
        
        // when
        let finding = usecase.loadSuggestAddNewItemByURLExists()
        let url = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNotNil(url)
    }
    
    func testUsecase_whenCopiedTextIsNotExists_suggestAddItemIsNil() {
        // given
        let expect = expectation(description: "복사된 텍스트 없을경우 추가 서제스트 안함")
        let usecase = self.makeUsecase(copiedText: nil)
        
        // when
        let finding = usecase.loadSuggestAddNewItemByURLExists()
        let url = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNil(url)
    }
    
    func testUsecase_whenCopiedTextIsNotURL_notSuggestAddItem() {
        // given
        let expect = expectation(description: "복사된 텍스트가 url이 아닐떼 추가 서제스트 안함")
        let usecase = self.makeUsecase(copiedText: "not url text")
        
        // when
        let finding = usecase.loadSuggestAddNewItemByURLExists()
        let url = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNil(url)
    }
    
    func testUsecase_whenCopiedURLIsShareURL_ignore() {
        // given
        let expect = expectation(description: "복사된 텍스트가 서비스 공유 url이면 추천 안함")
        let usecase = self.makeUsecase(copiedText: "readminds://share/collection?id=share_id")
        
        // when
        let finding = usecase.loadSuggestAddNewItemByURLExists()
        let url = self.waitFirstElement(expect, for: finding.asObservable())
        
        // then
        XCTAssertNil(url)
    }
    
    func testUsecase_whenCopiedURLIsAlreadySuggested_notSuggestAddItem() {
        // given
        let expect = expectation(description: "이미 서제스트 한번 요청했던 rul이면 서제스트 안함")
        let usecase = self.makeUsecase(copiedText: "https://www.naver.com")
        
        self.spyStore.save(Set<String>.self, key: .addSuggestedURLSet, ["https://www.naver.com"])
        // when
        let find = usecase.loadSuggestAddNewItemByURLExists()
        let url = self.waitFirstElement(expect, for: find.asObservable())
        
        // then
        XCTAssertNil(url)
    }
}


extension ReadItemUsecaseTests {
    
    func testUsecase_updateIsReloadNeed() {
        // given
        let usecase = self.makeUsecase(isReloadNeed: true)
        
        // when + then
        XCTAssertEqual(usecase.isReloadNeed, true)
        usecase.isReloadNeed = false
        XCTAssertEqual(usecase.isReloadNeed, false)
    }
}

extension ReadItemUsecaseTests {
    
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

extension ReadItemUpdateEvent {
    
    var remindTime: TimeStamp? {
        guard case let .updated(item) = self else { return nil }
        return item.remindTime
    }
}

//
//  FavoriteItemsPagingUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/12/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit
import Domain


class FavoriteItemsPagingUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var loadErrorMocking: ((Error?) -> Void)?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.loadErrorMocking = nil
    }
    
    private var dummyFavoriteIDs: [String] {
        return (0..<23).map { "id:\($0)" }
    }
    
    private func makeUsecase() -> FavoriteItemsPagingUsecase {
        
        let favoriteUsecase = StubFavoriteUsecase()
            |> \.ids .~ self.dummyFavoriteIDs
        let stubReposioty = StubReadItemRepository()
        self.loadErrorMocking = { error in
            stubReposioty.loadItemsByIDsErrorMocking = error
        }
        let sharedStore = SharedDataStoreServiceImple()
        let readUsecase = ReadItemUsecaseImple(itemsRespoitory: stubReposioty,
                                               previewRepository: StubLinkPreviewRepository(),
                                               optionsRespository: StubReadItemOptionsRepository(scenario: .init()),
                                               authInfoProvider: sharedStore,
                                               sharedStoreService: sharedStore,
                                               clipBoardService: StubClipBoardService(),
                                               readItemUpdateEventPublisher: nil,
                                               remindMessagingService: StubReminderMessagingService(),
                                               shareURLScheme: "readminds")
        return FavoriteItemsPagingUsecaseImple(favoriteItemsUsecase: favoriteUsecase,
                                               itemsLoadUsecase: readUsecase,
                                               throttleInterval: 0)
    }
}


extension FavoriteItemsPagingUsecaseTests {
    
    // 최초에 최근 아이템 10개 로드
    func testUscase_loadLatestItemsAtFirst() {
        // given
        let expect = expectation(description: "최초 로드시에 최근데이터 10개 로드")
        let usecase = self.makeUsecase()
        
        // when
        let source = usecase.items.skip(while: { $0.isEmpty })
        let firstItems = self.waitFirstElement(expect, for: source) {
            usecase.reloadFavoriteItems()
        }
        
        // then
        let ids = firstItems?.map { $0.uid }
        XCTAssertEqual(ids, self.dummyFavoriteIDs.reversed()[0..<10] |> Array.init)
    }
    
    func testUscase_loadMoresUntilEnd() {
        // given
        let expect = expectation(description: "데이터 있는동안 계속 더불러오기")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let source = usecase.items.skip(while: { $0.isEmpty })
        let itemLists = self.waitElements(expect, for: source) {
            usecase.reloadFavoriteItems() // 22...13
            usecase.loadMoreItems() // 12~3
            usecase.loadMoreItems() // 2~0
            usecase.loadMoreItems() // no
        }
        
        // then
        let idLists = itemLists.map { $0.map { $0.uid} }
        XCTAssertEqual(idLists, [
            self.dummyFavoriteIDs.reversed()[0..<10] |> Array.init,
            self.dummyFavoriteIDs.reversed()[0..<20] |> Array.init,
            self.dummyFavoriteIDs.reversed()[0..<23] |> Array.init
        ])
    }
    
    // 처음 10개 로드 + 더불러오기 1회 실패 + 이후 다시 로드시 두번쨰페이지 정상 로드
    func testUsecase_whenErrorOccurDurringLoading_ignoreAndRecoverNextTime() {
        // given
        let expect = expectation(description: "데이터 로딩중 에러발생하면 무시하고 다음번 로딩때 복구")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let source = usecase.items.skip(while: { $0.isEmpty })
        let itemLists = self.waitElements(expect, for: source) {
            usecase.reloadFavoriteItems() // 22...13
            usecase.loadMoreItems() // 12~3
            self.loadErrorMocking?(ApplicationErrors.invalid)
            usecase.loadMoreItems() // error -> ignore
            self.loadErrorMocking?(nil)
            usecase.loadMoreItems() // 2~0
        }
        
        // then
        let idLists = itemLists.map { $0.map { $0.uid} }
        XCTAssertEqual(idLists, [
            self.dummyFavoriteIDs.reversed()[0..<10] |> Array.init,
            self.dummyFavoriteIDs.reversed()[0..<20] |> Array.init,
            self.dummyFavoriteIDs.reversed()[0..<23] |> Array.init
        ])
    }
    
    // 처음부터 다시로드
    func testUsecase_reloadFromFirst() {
        // given
        let expect = expectation(description: "로드하다 처음부터 다시로드")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let source = usecase.items.skip(while: { $0.isEmpty })
        let itemLists = self.waitElements(expect, for: source) {
            usecase.reloadFavoriteItems() // 22...13
            usecase.loadMoreItems() // 12~3
            usecase.reloadFavoriteItems() // 22...13
        }
        
        // then
        let idLists = itemLists.map { $0.map { $0.uid} }
        XCTAssertEqual(idLists, [
            self.dummyFavoriteIDs.reversed()[0..<10] |> Array.init,
            self.dummyFavoriteIDs.reversed()[0..<20] |> Array.init,
            self.dummyFavoriteIDs.reversed()[0..<10] |> Array.init
        ])
    }
}


extension FavoriteItemsPagingUsecaseTests {
    
    
    class StubFavoriteUsecase: FavoriteReadItemUsecas {
        
        var ids: [String] = []
        func refreshFavoriteIDs() -> Observable<[String]> {
            return .from([self.ids, self.ids])
        }
        
        func refreshSharedFavoriteIDs() { }
        
        func toggleFavorite(itemID: String, toOn: Bool) -> Maybe<Void> { .empty() }
        
        var sharedFavoriteItemIDs: Observable<[String]> { .empty() }
    }
}

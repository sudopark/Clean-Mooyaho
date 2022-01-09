//
//  ReadItemUsecaseTests+SuggestRead.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit

import Domain


extension ReadItemUsecaseTests {
    
    func testUsecase_sugestNextReadItem() {
        // given
        let expect = expectation(description: "다음 읽을목록 추천받음")
        let usecas = self.makeUsecase()
        
        // when
        let suggesting = usecas.suggestNextReadItem(size: 5)
        let items = self.waitFirstElement(expect, for: suggesting.asObservable())
        
        // then
        XCTAssertEqual(items?.isNotEmpty, true)
    }
    
    func testUsecase_loadItemsByIDs() {
        // given
        let expect = expectation(description: "item id들도 아이템 로드")
        let usecase = self.makeUsecase()
        
        // when
        let ids = (0..<10).map { "id:\($0)" }
        let loading = usecase.loadReadItems(for: ids)
        let items = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 10)
    }
}

extension ReadItemUsecaseTests {
    
    // when load continue reading links
    func testUsecase_provideContinueReadingLinks() {
        // given
        let expect = expectation(description: "계속 읽음 아이템 목록 제공")
        let usecase = self.makeUsecase()
        
        // when
        let links = self.waitFirstElement(expect, for: usecase.continueReadingLinks())
        
        // then
        XCTAssertEqual(links?.isNotEmpty, true)
    }
    
    func testUsecase_appendItemAtContinueReadingList() {
        // given
        let expect = expectation(description: "계속 읽음 아이템 목록에 추가")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let linkLists = self.waitElements(expect, for: usecase.continueReadingLinks()) {
            usecase.updateLinkIsReading(.dummy(2, parent: nil))
        }
        
        // then
        XCTAssertEqual(linkLists.map { $0.count }, [1, 2])
    }
    
    // when load continue reading links + remove when read
    func testUsecase_whenItemMarkAsRead_removeFromContinueReadingList() {
        // given
        let expect = expectation(description: "해당 아이템이 읽기 처리 되었다면 읽기 계속읽기 목록에서 제거")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let links = self.waitElements(expect, for: usecase.continueReadingLinks()) {
            let dummy = ReadLink.dummy(0, parent: nil)
            usecase.updateLinkItemMark(dummy, asRead: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(links.map { $0.count }, [1, 0])
    }
}


extension ReadItemUsecaseTests {
    
    // bind favorite item ids and refresh
    func testUsecase_provideSharedFavoriteItemIDs() {
        // given
        let expect = expectation(description: "즐겨찾는 아이템 아이디 목록 제공")
        let usecase = self.makeUsecase()
        
        // when
        let ids = self.waitFirstElement(expect, for: usecase.sharedFavoriteItemIDs) {
            usecase.refreshSharedFavoriteIDs()
        }
        
        // then
        XCTAssertEqual(ids, ["some"])
    }
    
    // refresh => also update
    func testUsecase_whenAfterRefreshFavoriteItemIDs_updateSharedIDs() {
        // given
        let expect = expectation(description: "즐겨찾는 아이템 아이디 refresh 이후에 공유되는 목록도 같이 업데이트")
        expect.expectedFulfillmentCount = 2
        let usecase = self.makeUsecase()
        
        // when
        let idLists = self.waitElements(expect, for: usecase.sharedFavoriteItemIDs) {
            usecase.refreshSharedFavoriteIDs()
            usecase.refreshFavoriteIDs()
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(idLists, [["some"], ["some", "new"]])
    }
    
    // toggle favorite
    func testUsecase_updateSharedFavoriteItemIDs_byToggling() {
        // given
        let expect = expectation(description: "즐겨찾는 아이템 목록 토글")
        expect.expectedFulfillmentCount = 3
        let usecase = self.makeUsecase()
        
        // when
        let idLists = self.waitElements(expect, for: usecase.sharedFavoriteItemIDs) {
            usecase.refreshSharedFavoriteIDs()
            let toggleOffAndOn = usecase.toggleFavorite(itemID: "some", toOn: false)
                .flatMap { usecase.toggleFavorite(itemID: "new", toOn: true) }
            toggleOffAndOn
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(idLists, [
            ["some"], [],  ["new"]
        ])
    }
}

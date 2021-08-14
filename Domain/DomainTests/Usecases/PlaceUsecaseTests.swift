//
//  PlaceUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/08/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

import Domain


class PlaceUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyStore: SharedDataStoreService!
    private var dummyPlace: Place!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.dummyPlace = Place.dummy(0)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.dummyPlace = nil
        self.spyStore = nil
    }
    
    private func makeUsecase(hasLocalPlace: Bool = true) -> PlaceUsecase {
        
        let stubRepository = StubPlaceRepository()
        hasLocalPlace.then {
            stubRepository.savePlace(self.dummyPlace)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        let store = SharedDataStoreServiceImple()
        self.spyStore = store
        
        return PlaceUsecaseImple(placeRepository: stubRepository, sharedStoreService: store)
    }
}



extension PlaceUsecaseTests {
    
    private var placeID: String { self.dummyPlace.uid }
    
    func testUsecase_loadPlaceInfo() {
        // given
        let expect = expectation(description: "장소정보 로드")
        let usecase = self.makeUsecase()
        
        // when
        let place = self.waitElements(expect, for: usecase.loadPlace(self.placeID).asObservable())
        
        // then
        XCTAssertNotNil(place)
    }
    
    func testUsecase_whenAfterLoadPlace_updateSharedPlaceMap() {
        // given
        let expect = expectation(description: "place load 이후에 공유되는 placeMap 업데이트")
        let usecase = self.makeUsecase()
        
        // when
        let key = SharedDataKeys.placeMap.rawValue
        let placeSource = self.spyStore.observe([String: Place].self, key: key).compactMap{ $0 }
        let updatedPlaces = self.waitFirstElement(expect, for: placeSource) {
            usecase.loadPlace(self.placeID)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        let place = updatedPlaces?[self.placeID]
        XCTAssertNotNil(place)
    }
    
    func testUsecase_whenSubscribePlace_startLocalPlaceInfoIfExists_andNotExistsOnStore() {
        // given
        let expect = expectation(description: "place 정보 구독시 로컬에 저장된값 있으면 해당값부터 시작")
        let usecase = self.makeUsecase()
        
        // when
        let places = self.waitElements(expect, for: usecase.place(self.placeID))
        
        // then
        XCTAssertEqual(places.count, 1)
    }

    func testUsecase_refreshPlace() {
        // given
        let expect = expectation(description: "장소정보 refresh")
        let usecase = self.makeUsecase(hasLocalPlace: false)
        
        // when
        let places = self.waitElements(expect, for: usecase.place(self.placeID)) {
            usecase.refreshPlace(self.placeID)
        }
        
        // then
        XCTAssertEqual(places.count, 1)
    }
}

//
//  RepositoryTests+Places.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class RepositoryTests_Places: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.mockRemote = MockRemote()
        self.mockLocal = MockLocal()
        self.repository = DummyRepository(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.repository = nil
        super.tearDown()
    }
}


extension RepositoryTests_Places {
    
    func testRepo_uploadUserLocation() {
        // given
        let expect = expectation(description: "유저 현재위치 업로드")
        self.mockRemote.register(key: "requesUpload:location") {
            return Maybe<Void>.just()
        }
        
        // when
        let location = UserLocation.dummy(0)
        let void = self.waitFirstElement(expect, for: self.repository.uploadLocation(location).asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testRepo_requestDefaultPlaceSuggest() {
        // given
        let expect = expectation(description: "해당 장소의 디폴트 서제스트 로드")
        self.mockRemote.register(type: Maybe<SuggestPlaceResult>.self,key: "requestLoadDefaultPlaceSuggest") {
            return .just(.init(default: []))
        }
        
        // when
        let location = UserLocation.dummy(0)
        let result = self.waitFirstElement(expect, for: self.repository.reqeustLoadDefaultPlaceSuggest(in: location).asObservable()) { }
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_requestPlaceSuggest() {
        // given
        let expect = expectation(description: "해당 장소 + 쿼리에 해당하는 서제스트 로드")
        self.mockRemote.register(type: Maybe<SuggestPlaceResult>.self,key: "requestSuggestPlace") {
            return .just(.init(query: "some", places: []))
        }

        // when
        let location = UserLocation.dummy(0)
        let result = self.waitFirstElement(expect, for: self.repository.requestSuggestPlace("some", in: location, cursor: nil).asObservable()) { }

        // then
        XCTAssertNotNil(result)
    }
    
    func testRepo_loadPlace() {
        // given
        let expect = expectation(description: "특정 장소 로드")
        self.mockRemote.register(key: "requestLoadPlace") {
            return Maybe<Place>.just(self.dummyPlace)
        }
        
        // when
        let requestLoad = self.repository.requestLoadPlace("some")
        let place = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(place)
    }
    
    func testRepo_whenAfterLoadPlace_updateCache() {
        // given
        let expect = expectation(description: "특정 장소 로드 이후에 케시 업데이트")
        self.mockRemote.register(key: "requestLoadPlace") {
            return Maybe<Place>.just(self.dummyPlace)
        }
        
        self.mockLocal.called(key: "savePlaces") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestLoadPlace("some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


// MARK - register new place

extension RepositoryTests_Places {
    
    func testRepository_fetchRegisterPendingNewPlaceForm() {
        // given
        let expect = expectation(description: "등록 대기중인 새 장소 양식 로드")
        
        self.mockLocal.register(type: Maybe<PendingRegisterNewPlaceForm?>.self, key: "fetchRegisterPendingNewPlaceForm") {
            let form = NewPlaceForm(reporterID: "some", infoProvider: .userDefine)
            return .just((form, Date()))
        }
        
        // when
        let requestLoad = self.repository.fetchRegisterPendingNewPlaceForm("some")
        let form = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(form)
    }
    
    func testRepository_savePendingRegisterNewPlaceForm() {
        // given
        let expect = expectation(description: "등록 대기중인 장소정보 저장")
        self.mockLocal.register(key: "savePendingRegister") {
            return Maybe<Void>.just()
        }
        
        // when
        let requestSave = self.repository.savePendingRegister(newPlace: .init(reporterID: "some", infoProvider: .userDefine))
        let saved: Void? = self.waitFirstElement(expect, for: requestSave.asObservable()) { }
        
        // then
        XCTAssertNotNil(saved)
    }
    
    private var dummyPlace: Place {
        Place(uid: "", title: "", coordinate: .init(latt: 0, long: 0), address: "", categoryTags: [], reporterID: "", infoProvider: .externalSearch, createdAt: 0, pickCount: 0, lastPickedAt: 0)
    }
    
    func testRepository_regisgerNewPlace() {
        // given
        let expect = expectation(description: "새로운 장소 등록 요청")
        
        self.mockRemote.register(key: "requestRegister:place") {
            return Maybe<Place>.just(self.dummyPlace)
        }
        
        // when
        let requestRegister = self.repository.requestRegister(newPlace: .init(reporterID: "", infoProvider: .externalSearch))
        let newPlace = self.waitFirstElement(expect, for: requestRegister.asObservable()) { }
        
        // then
        XCTAssertNotNil(newPlace)
    }
    
    func testRepository_whenAfterRegisgerNewPlace_saveResultAtLocal() {
        // given
        let expect = expectation(description: "새로운 장소 등록 하고 로컬에도 저장")
        
        self.mockRemote.register(key: "requestRegister:place") {
            return Maybe<Place>.just(self.dummyPlace)
        }
        
        self.mockLocal.called(key: "savePlaces") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestRegister(newPlace: .init(reporterID: "", infoProvider: .userDefine))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_whenAfterRegisgerNewPlace_removePendingInputForm() {
        // given
        let expect = expectation(description: "새로운 장소 등록 하고 이전에 입력중이던 항목 삭제")
        
        self.mockRemote.register(key: "requestRegister:place") {
            return Maybe<Place>.just(self.dummyPlace)
        }
        
        self.mockLocal.called(key: "removePendingRegisterForm") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestRegister(newPlace: .init(reporterID: "", infoProvider: .userDefine))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}



extension RepositoryTests_Places {
    
    class DummyRepository: PlaceRepository, PlaceRepositoryDefImpleDependency {
        let placeRemote: PlaceRemote
        let placeLocal: PlaceLocalStorage
        let disposeBag: DisposeBag = .init()
        init(remote: PlaceRemote, local: PlaceLocalStorage) {
            self.placeRemote = remote
            self.placeLocal = local
        }
    }
}


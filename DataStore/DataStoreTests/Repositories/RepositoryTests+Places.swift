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
    var stubRemote: StubRemote!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubRemote = StubRemote()
        self.repository = DummyRepository(remote: self.stubRemote)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubRemote = nil
        self.repository = nil
        super.tearDown()
    }
}


extension RepositoryTests_Places {
    
    func testRepo_uploadUserLocation() {
        // given
        let expect = expectation(description: "유저 현재위치 업로드")
        self.stubRemote.register(key: "requesUpload:location") {
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
        self.stubRemote.register(type: Maybe<SuggestPlaceResult>.self,key: "requestLoadDefaultPlaceSuggest") {
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
        self.stubRemote.register(type: Maybe<DataModels.SuggestPlaceResult>.self,key: "requestSuggestPlace") {
            return .just(.init(query: "some", places: []))
        }

        // when
        let location = UserLocation.dummy(0)
        let result = self.waitFirstElement(expect, for: self.repository.requestSuggestPlace("some", in: location, cursor: nil).asObservable()) { }

        // then
        XCTAssertNotNil(result)
    }
}


extension RepositoryTests_Places {
    
    class DummyRepository: PlaceRepository, PlaceRepositoryDefImpleDependency {
        let remote: Remote
        init(remote: Remote) {
            self.remote = remote
        }
    }
}


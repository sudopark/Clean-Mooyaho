//
//  FirebaseServiceImpleTest+PlaceRemote.swift
//  FirebaseServiceTests
//
//  Created by sudo.park on 2021/05/08.
//

import XCTest

import RxSwift

import Domain
import DataStore
import UnitTestHelpKit

@testable import FirebaseService


class FirebaseServiceImpleTest_PlaceRemote: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubSession: StubSession!
    var fakeRemote: FakeHttpRemote!
    var service: FirebaseServiceImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubSession = .init()
        self.fakeRemote = FakeHttpRemote(session: self.stubSession)
        self.service = FirebaseServiceImple(httpRemote: self.fakeRemote)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubSession = nil
        self.fakeRemote = nil
        self.service = nil
        super.tearDown()
    }
}

extension FirebaseServiceImpleTest_PlaceRemote {
    
    func test_loadSearchPlaceCollection() {
        // given
        let expect = expectation(description: "장소 검색결과 로드해서 디코딩")
        self.stubSession.register(type: Maybe<HttpResponse>.self, key: "requestData") {
            let data = readJsonAsData("SearchPlace")!
            let response = HttpResponse(urlResponse: nil, dataResult: .success(data))
            return .just(response)
        }
        
        // when
        let location = UserLocation(userID: "id0", lastLocation: .init(lattitude: 0, longitude: 0, timeStamp: 0))
        let collection = self.waitFirstElement(expect, for: self.service.requestSearchNewPlace("커피", in: location, of: nil).asObservable()) {}
        
        // then
        XCTAssertEqual(collection?.query, "커피")
        XCTAssertEqual(collection?.currentPage, 1)
        XCTAssertEqual(collection?.places.count, 10)
    }
}


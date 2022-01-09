//
//  FirebaseServiceImpleTests.swift
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


class FirebaseServiceImpleTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockSession: MockSession!
    var fakeHttpAPI: FakeHttpAPI!
    var service: FirebaseServiceImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.mockSession = .init()
        self.fakeHttpAPI = FakeHttpAPI(session: self.mockSession)
        self.service = FirebaseServiceImple(httpAPI: self.fakeHttpAPI,
                                            serverKey: "dummy",
                                            previewRemote: DummyPreviewRemote())
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockSession = nil
        self.fakeHttpAPI = nil
        self.service = nil
        super.tearDown()
    }
}


// MARK: - search place

extension FirebaseServiceImpleTests {
    
    func test_loadSearchPlaceCollection() {
        // given
        let expect = expectation(description: "장소 검색결과 로드해서 디코딩")
        self.mockSession.register(type: Maybe<HttpResponse>.self, key: "requestData") {
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


// MARK: - send message

extension FirebaseServiceImpleTests {
    
    func test_messagePayload() {
        // given
        let hoorayAckMessage = HoorayAckMessage(hoorayID: "dummy", publisherID: "h_owner", ackUserID: "ack_sender")
        
        // when
        let payload = hoorayAckMessage.asDataPayload()
        
        // then
        
        XCTAssertEqual(payload["m_type"] as? String, "hooray_ack")
        XCTAssertEqual(payload["ack_uid"] as? String, "ack_sender")
        XCTAssertEqual(payload["hid"] as? String, "dummy")
    }
}


extension FirebaseServiceImpleTests {
    
    class DummyPreviewRemote: LinkPreviewRemote {
        
        func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> {
            return .empty()
        }
    }
}

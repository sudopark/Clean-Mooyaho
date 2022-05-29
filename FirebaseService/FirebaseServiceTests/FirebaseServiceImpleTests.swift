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


extension FirebaseServiceImpleTests {
    
    class DummyPreviewRemote: LinkPreviewRemote {
        
        func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> {
            return .empty()
        }
    }
}

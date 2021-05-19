//
//  RepositoryTests+Hooray.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/05/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class RepositoryTests_Hooray: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubRemote: StubRemote!
    var stubLocal: StubLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubLocal = .init()
        self.stubRemote = .init()
        self.repository = .init(remote: self.stubRemote, local: self.stubLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubRemote = nil
        self.stubLocal = nil
        self.repository = nil
        super.tearDown()
    }
}


extension RepositoryTests_Hooray {
    
    private func dummyHooray(_ int: Int = 0) -> Hooray {
        return .init(uid: "id:\(int)", placeID: "place:\(int)", publisherID: "pub:\(int)"
                     , location: .init(latt: 0, long: 0), timestamp: 0,
                     ackUserIDs: [], reactions: [], spreadDistance: 0, aliveDuration: 0)
    }
    
    func testRepository_fetchRecentMyHoorayAtLocal() {
        // given
        let expect = expectation(description: "로컬에 저장된 최근 후레이 조회")
        
        self.stubLocal.register(key: "fetchLatestHooray") {
            return Maybe<Hooray?>.just(self.dummyHooray())
        }
        
        // when
        let requestFetch = self.repository.fetchLatestHooray("soem")
        let lastest = self.waitFirstElement(expect, for: requestFetch.asObservable()) { }
        
        // then
        XCTAssertEqual(lastest?.id, self.dummyHooray().uid)
    }
    
    func testRepository_loadLatestHoorayFromRemote() {
        // given
        let expect = expectation(description: "리모트에서 최근 후레이 조회")
        
        self.stubRemote.register(key: "requestLoadLatestHooray") {
            return Maybe<Hooray?>.just(self.dummyHooray())
        }
        
        // when
        let requestLoad = self.repository.requestLoadLatestHooray("some")
        let lastest = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertEqual(lastest?.id, self.dummyHooray().uid)
    }
    
    func testRepository_whenAfterLoadLatestHoorayFromRemote_saveAtLocal() {
        // given
        let expect = expectation(description: "리모트에서 최근 후레이 조회 이후에 로컬에 저장")
        
        self.stubRemote.register(key: "requestLoadLatestHooray") {
            return Maybe<Hooray?>.just(self.dummyHooray())
        }
        
        self.stubLocal.called(key: "saveHoorays") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestLoadLatestHooray("some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_requestAckHooray() {
        // given
        let expect = expectation(description: "리모트에서 후레이 ack 처리")
        
        self.stubRemote.register(key: "requestAckHooray") {
            return Maybe<Void>.just()
        }
        
        // when
        let requestAck = self.repository.requestAckHooray("some", at: "hid")
        let void: Void? = self.waitFirstElement(expect, for: requestAck.asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
}

extension RepositoryTests_Hooray {
    
    func testRepository_publishNewHooray() {
        // given
        let expect = expectation(description: "새로운 후레이 발행")
        
        self.stubRemote.register(key: "requestPublishHooray") {
            return Maybe<Hooray>.just(self.dummyHooray())
        }
        
        // when
        let form = NewHoorayForm(publisherID: "some")
        let requestPublish = self.repository.requestPublishHooray(form, withNewPlace: nil)
        let newHooray = self.waitFirstElement(expect, for: requestPublish.asObservable()) { }
        
        // then
        XCTAssertNotNil(newHooray)
    }
    
    func testRepository_whenAfterPublishNewHooray_saveAtLocal() {
        // given
        let expect = expectation(description: "새로운 후레이 발행 이후 로컬에 저장")
        self.stubRemote.register(key: "requestPublishHooray") {
            return Maybe<Hooray>.just(self.dummyHooray())
        }
        
        self.stubLocal.called(key: "saveHoorays") { _ in
            expect.fulfill()
        }
        
        // when
        let form = NewHoorayForm(publisherID: "some")
        self.repository.requestPublishHooray(form, withNewPlace: nil)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_loadNeerbyRecentHoorays() {
        // given
        let expect = expectation(description: "주변에 있는 최근 후레이 조회")
        
        self.stubRemote.register(key: "requestLoadNearbyRecentHoorays") {
            return Maybe<[Hooray]>.just([self.dummyHooray()])
        }
        
        // when
        let requestLoad = self.repository.requestLoadNearbyRecentHoorays(at: .init(latt: 0, long: 0))
        let hoorays = self.waitFirstElement(expect, for: requestLoad.asObservable()) {}
        
        // then
        XCTAssertEqual(hoorays?.count, 1)
    }
}


extension RepositoryTests_Hooray {
    
    class DummyRepository: HoorayRepository, HoorayRepositoryDefImpleDependency {
        
        let remote: HoorayRemote
        let local: HoorayLocalStorage
        let disposeBag: DisposeBag = .init()
        
        init(remote: HoorayRemote, local: HoorayLocalStorage) {
            self.remote = remote
            self.local = local
        }
    }
}

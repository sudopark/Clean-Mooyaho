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
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.mockLocal = .init()
        self.mockRemote = .init()
        self.repository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.repository = nil
        super.tearDown()
    }
}


extension RepositoryTests_Hooray {
    
    private func dummyHooray(_ int: Int = 0) -> Hooray {
        return .init(uid: "id:\(int)", placeID: "place:\(int)",
                     publisherID: "pub:\(int)",
                     hoorayKeyword: .default, message: "hi",
                     location: .init(latt: 0, long: 0), timestamp: 0,
                     spreadDistance: 0, aliveDuration: 0)
    }
    
    func testRepository_fetchRecentMyHoorayAtLocal() {
        // given
        let expect = expectation(description: "로컬에 저장된 최근 후레이 조회")
        
        self.mockLocal.register(key: "fetchLatestHoorays") {
            return Maybe<[Hooray]>.just([self.dummyHooray()])
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
        
        self.mockRemote.register(key: "requestLoadLatestHooray") {
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
        
        self.mockRemote.register(key: "requestLoadLatestHooray") {
            return Maybe<Hooray?>.just(self.dummyHooray())
        }
        
        self.mockLocal.called(key: "saveHoorays") { _ in
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
        
        self.mockRemote.called(key: "requestAckHooray") { _ in
            expect.fulfill()
        }
        
        // when
        let ack = HoorayAckMessage(hoorayID: "some", publisherID: "p_id", ackUserID: "ack_id")
        self.repository.requestAckHooray([ack])
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension RepositoryTests_Hooray {
    
    func testRepository_publishNewHooray() {
        // given
        let expect = expectation(description: "새로운 후레이 발행")
        
        self.mockRemote.register(key: "requestPublishHooray") {
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
        self.mockRemote.register(key: "requestPublishHooray") {
            return Maybe<Hooray>.just(self.dummyHooray())
        }
        
        self.mockLocal.called(key: "saveHoorays") { _ in
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
        
        self.mockRemote.register(key: "requestLoadNearbyRecentHoorays") {
            return Maybe<[Hooray]>.just([self.dummyHooray()])
        }
        
        // when
        let requestLoad = self.repository.requestLoadNearbyRecentHoorays(at: .init(latt: 0, long: 0))
        let hoorays = self.waitFirstElement(expect, for: requestLoad.asObservable()) {}
        
        // then
        XCTAssertEqual(hoorays?.count, 1)
    }
    
    func testRepository_whenAfterLoadRecentHoorays_saveAtCache() {
        // given
        let expect = expectation(description: "주변에 있는 최근 후레이 조회 이후에 로컬에 후레이 저장")
        
        self.mockRemote.register(key: "requestLoadNearbyRecentHoorays") {
            return Maybe<[Hooray]>.just([self.dummyHooray()])
        }
        self.mockLocal.called(key: "saveHoorays") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestLoadNearbyRecentHoorays(at: .init(latt: 0, long: 0))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_loadHooray() {
        // given
        let expect = expectation(description: "후레이 조회")
        self.mockRemote.register(key: "requestLoadHooray") {
            return Maybe<Hooray?>.just(self.dummyHooray())
        }
        
        // when
        let requestLoad = self.repository.requestLoadHooray("some").asObservable()
        let hooray = self.waitFirstElement(expect, for: requestLoad)
        
        // then
        XCTAssertNotNil(hooray)
    }
    
    func testRepository_whenLoadNotExistsHooray_error() {
        // given
        let expect = expectation(description: "존재안하는 후레이 조회시에 에러")
        self.mockRemote.register(key: "requestLoadHooray") {
            return Maybe<Hooray?>.just(nil)
        }
        
        // when
        let requestLoad = self.repository.requestLoadHooray("some").asObservable()
        let error = self.waitError(expect, for: requestLoad)
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testRepository_whenAfterLoadHooray_saveToCache() {
        // given
        let expect = expectation(description: "후레이 조회 이후에 로컬에 저장")
        self.mockRemote.register(key: "requestLoadHooray") {
            return Maybe<Hooray?>.just(self.dummyHooray())
        }
        self.mockLocal.called(key: "saveHoorays") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestLoadHooray("some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testRepository_fetchHoorayDetail() {
        // given
        let expect = expectation(description: "hooray detail fetch")
        
        self.mockLocal.register(key: "fetchHoorayDetail") {
            return Maybe<HoorayDetail?>.just(.init(info: self.dummyHooray(), acks: [], reactions: []))
        }
        
        // when
        let fetching = self.repository.fetchHoorayDetail("some").asObservable()
        let detail = self.waitFirstElement(expect, for: fetching)
        
        // then
        XCTAssertNotNil(detail)
    }
    
    func testRepository_loadHoorayDetailFromRemote() {
        // given
        let expect = expectation(description: "load hooray detail from remote")
        
        self.mockRemote.register(key: "requestLoadHoorayDetail") {
            return Maybe<HoorayDetail>.just(.init(info: self.dummyHooray(), acks: [], reactions: []))
        }
        
        // when
        let loading = self.repository.requestLoadHoorayDetail("some").asObservable()
        let detail = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertNotNil(detail)
    }
    
    func testRepository_whenAfterLoadHoorayDetail_updateLocal() {
        // given
        let expect = expectation(description: "hooray detail 리모트에서 조회 이후에 로컬에 저장")
        
        self.mockRemote.register(key: "requestLoadHoorayDetail") {
            return Maybe<HoorayDetail>.just(.init(info: self.dummyHooray(), acks: [], reactions: []))
        }
        
        self.mockLocal.called(key: "saveHoorayDetail") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository.requestLoadHoorayDetail("some")
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension RepositoryTests_Hooray {
    
    class DummyRepository: HoorayRepository, HoorayRepositoryDefImpleDependency {
        
        let hoorayRemote: HoorayRemote
        let hoorayLocal: HoorayLocalStorage
        let disposeBag: DisposeBag = .init()
        
        init(remote: HoorayRemote, local: HoorayLocalStorage) {
            self.hoorayRemote = remote
            self.hoorayLocal = local
        }
    }
}

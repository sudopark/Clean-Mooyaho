//
//  RepositoryTests+LinkPreview.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class RepositoryTests_LinkPreview: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    
    var dummyRepository: DummyRepository!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockRemote = .init()
        self.mockLocal = .init()
        self.dummyRepository = .init(remote: self.mockRemote, local: self.mockLocal)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.dummyRepository = nil
    }
    
    private var dummyURL: String {
        return "https://www.domain.com"
    }
}


extension RepositoryTests_LinkPreview {
    
    func testRepository_loadLinkPreview() {
        // given
        let expect = expectation(description: "link preview 로드")
        self.mockLocal.register(key: "fetchPreview") {
            return Maybe<LinkPreview?>.just(nil)
        }
        self.mockRemote.register(key: "requestLoadPreview") {
            return Maybe<LinkPreview>.just(.dummy)
        }
        
        // when
        let loading = self.dummyRepository.loadLinkPreview(self.dummyURL)
        let preview = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(preview)
    }
    
    func testRepository_whenCacheExists_loadLinkPreview() {
        // given
        let expect = expectation(description: "link preview 캐시에 존재시 로드")
        
        self.mockLocal.register(key: "fetchPreview") {
            return Maybe<LinkPreview?>.just(.dummy)
        }
        
        // when
        let loading = self.dummyRepository.loadLinkPreview(self.dummyURL)
        let preview = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(preview)
    }
    
    func testRepository_whenFetchCacheFail_ignoreAndLoadFromRemote() {
        // given
        let expect = expectation(description: "link preview 로드시에 캐시조회에 실패하면 리모트에서 로드")
        self.mockLocal.register(key: "fetchPreview") {
            return Maybe<LinkPreview?>.error(LocalErrors.invalidData(nil))
        }
        self.mockRemote.register(key: "requestLoadPreview") {
            return Maybe<LinkPreview>.just(.dummy)
        }
        
        // when
        let loading = self.dummyRepository.loadLinkPreview(self.dummyURL)
        let preview = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(preview)
    }
    
    func testRepository_whenLoadPreviewFromRemote_updateCache() {
        // given
        let expect = expectation(description: "link preview remote에서 조회시에 캐시 업데이트")
        self.mockLocal.register(key: "fetchPreview") {
            return Maybe<LinkPreview?>.just(nil)
        }
        self.mockRemote.register(key: "requestLoadPreview") {
            return Maybe<LinkPreview>.just(.dummy)
        }
        
        self.mockLocal.called(key: "saveLinkPreview") { _ in
            expect.fulfill()
        }
        
        // when
        self.dummyRepository.loadLinkPreview(self.dummyURL)
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension RepositoryTests_LinkPreview {
    
    class DummyRepository: LinkPreviewRepository, LinkPreviewrepositoryDefImpleDependency {
        
        let previewRemote: LinkPreviewRemote
        let previewCache: LinkPreviewCacheStorage
        let disposeBag: DisposeBag = .init()
        
        init(remote: LinkPreviewRemote, local: LinkPreviewCacheStorage) {
            self.previewRemote = remote
            self.previewCache = local
        }
    }
}


private extension LinkPreview {
    
    static var dummy: Self {
        return LinkPreview(title: nil, description: nil, mainImageURL: nil, iconURL: nil)
    }
}

//
//  RepositoryTests+Member.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class RepositoryTests_Member: BaseTestCase, WaitObservableEvents {
    
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


extension RepositoryTests_Member {
    
    func testRepository_updateUserPresence() {
        // given
        let expect = expectation(description: "user presence 업데이트")
        
        self.stubRemote.register(key: "requestUpdateUserPresence") {
            return Maybe<Void>.just()
        }
        
        // when
        let requestUpdate = self.repository.requestUpdateUserPresence("som", isOnline: true)
        let void: Void? = self.waitFirstElement(expect, for: requestUpdate.asObservable()) { }
        
        // then
        XCTAssertNotNil(void)
    }
}


// MARK: - test update member profile

extension RepositoryTests_Member {
    
    // emoji는 바로 완료이벤트
    func testRepository_whenUploadEmoji_returnCompleted() {
        // given
        let expect = expectation(description: "업로드할 이미지가 이모지면 바로 완료")
        
        // when
        let requestUpload = self.repository
            .requestUploadMemberProfileImage("some", source: .emoji("😂"))
        let status = self.waitElements(expect, for: requestUpload)
        
        // then
        if case .completed(.emoji) = status.first {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 이벤트가 아님")
        }
    }
    
    // 데이터 업로드 이벤트 전달
    func testRepository_uploadImageAsData() {
        // given
        let expect = expectation(description: "data형식으로 이미지 업로드")
        expect.expectedFulfillmentCount = 2
        
        // when
        let requestUpload = self.repository
            .requestUploadMemberProfileImage("some", source: .data(Data(), extension: "jpg"))
        let status = self.waitElements(expect, for: requestUpload) {
            self.stubRemote.stubUploadMemberProfileImageStatus.onNext(.uploading(0.5))
            self.stubRemote.stubUploadMemberProfileImageStatus.onNext(.completed(.path("some")))
        }
        
        // then
        if case .uploading = status.first, case .completed = status.last {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 이벤트가 아님")
        }
    }
    
    // 파일은 임시경로에 복사하고 업로드
    
    // 원래 없는파일 요청시에 에러
    
    // 임시경로 복사 실패시에 에러
    
    // 필드 업데이트
    func testRepository_updateMemberFields() {
        // given
        let expect = expectation(description: "멤버 필드 새로운 값으로 업데이트")
        
        self.stubRemote.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(Member.init(uid: "some"))
        }
        
        // when
        let requestUpdate = self.repository
            .requestUpdateMemberProfileFields("some", fields: [.nickName("some")], imageSource: nil)
        let member = self.waitFirstElement(expect, for: requestUpdate.asObservable())
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testRepository_whenUpdateMember_updateLocal() {
        // given
        let expect = expectation(description: "멤버 업데이트 이후에 캐시 업데이트")
        
        self.stubRemote.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(Member.init(uid: "some"))
        }
        
        self.stubLocal.called(key: "updateCurrentMember") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository
            .requestUpdateMemberProfileFields("some", fields: [.nickName("some")], imageSource: .emoji("✊"))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension RepositoryTests_Member {
    
    class DummyRepository: MemberRepository, MemberRepositoryDefImpleDependency {
        
        let memberRemote: MemberRemote
        let memberLocal: MemberLocalStorage
        let disposeBag: DisposeBag = .init()
        
        init(remote: MemberRemote, local: MemberLocalStorage) {
            self.memberRemote = remote
            self.memberLocal = local
        }
    }
}

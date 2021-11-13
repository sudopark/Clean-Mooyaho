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
    var mockRemote: MockRemote!
    var mockLocal: MockLocal!
    var mockFileService: MockFileService!
    var repository: DummyRepository!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.mockLocal = .init()
        self.mockRemote = .init()
        self.mockFileService = .init()
        self.repository = .init(remote: self.mockRemote, local: self.mockLocal, fileHandle: self.mockFileService)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockRemote = nil
        self.mockLocal = nil
        self.mockFileService = nil
        self.repository = nil
        super.tearDown()
    }
}


extension RepositoryTests_Member {
    
    func testRepository_updateUserPresence() {
        // given
        let expect = expectation(description: "user presence 업데이트")
        
        self.mockRemote.register(key: "requestUpdateUserPresence") {
            return Maybe<Void>.just()
        }
        
        // when
        let requestUpdate = self.repository
            .requestUpdateUserPresence("som", deviceID: "dev_id", isOnline: true)
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
            .requestUploadMemberProfileImage("some", source: .data(Data(), extension: "jpg", size: .init(100, 100)))
        let status = self.waitElements(expect, for: requestUpload) {
            self.mockRemote.uploadMemberProfileImageStatus.onNext(.uploading(0.5))
            self.mockRemote.uploadMemberProfileImageStatus.onNext(.completed(.imageSource(.init(path: "some", size: .init(100, 100)))))
        }
        
        // then
        if case .uploading = status.first, case .completed = status.last {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 이벤트가 아님")
        }
    }
    
    // 파일은 임시경로에 복사하고 업로드
    func testRepository_uploadUserImage_withCoping() {
        // given
        let expect = expectation(description: "file 임시경로로 복사하고 업로드")
        expect.expectedFulfillmentCount = 2
        
        self.mockFileService.copyResultMocking = .success(())
        
        // when
        let params = ImageUploadReqParams.file("some", needCopyTemp: true, size: .init(100, 100))
        let uploading = self.repository.requestUploadMemberProfileImage("mid", source: params)
        let status = self.waitElements(expect, for: uploading) {
            self.mockRemote.uploadMemberProfileImageStatus.onNext(.uploading(0.5))
            self.mockRemote.uploadMemberProfileImageStatus.onNext(.completed(.imageSource(.init(path: "some", size: .init(100, 100)))))
        }
        
        // then
        if case .uploading = status.first, case .completed = status.last {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 이벤트가 아님")
        }
    }
    
    // 임시경로 복사 실패시에 에러
    func testRepository_whenCopyFailDuringUploadUserImage_uploadProcessIsFail() {
        // given
        let expect = expectation(description: "file 임시경로로 복사 실패시에 업로드 프로세스 실패")
        
        self.mockFileService.copyResultMocking = .failure(ApplicationErrors.invalid)
        
        // when
        let params = ImageUploadReqParams.file("some", needCopyTemp: true, size: .init(100, 100))
        let uploading = self.repository.requestUploadMemberProfileImage("mid", source: params)
        let error = self.waitError(expect, for: uploading)
        
        // then
        XCTAssertNotNil(error)
    }
    
    // 필드 업데이트
    func testRepository_updateMemberFields() {
        // given
        let expect = expectation(description: "멤버 필드 새로운 값으로 업데이트")
        
        self.mockRemote.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(Member.init(uid: "some"))
        }
        
        // when
        let requestUpdate = self.repository
            .requestUpdateMemberProfileFields("some", fields: [.nickName("some")], thumbnail: nil)
        let member = self.waitFirstElement(expect, for: requestUpdate.asObservable())
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testRepository_whenUpdateMember_updateLocal() {
        // given
        let expect = expectation(description: "멤버 업데이트 이후에 캐시 업데이트")
        
        self.mockRemote.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(Member.init(uid: "some"))
        }
        
        self.mockLocal.called(key: "updateCurrentMember") { _ in
            expect.fulfill()
        }
        
        // when
        self.repository
            .requestUpdateMemberProfileFields("some", fields: [.nickName("some")], thumbnail: .emoji("✊"))
            .subscribe()
            .disposed(by: self.disposeBag)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}

extension RepositoryTests_Member {
    
    func testRepository_fetchMembers() {
        // given
        let expect = expectation(description: "fetch members")
        self.mockLocal.register(key: "fetchMembers") {
            return Maybe<[Member]>.just([])
        }
        
        // when
        let fetching = self.repository.fetchMembers(["uid:1", "uid:2"])
        let members = self.waitFirstElement(expect, for: fetching.asObservable())
        
        // then
        XCTAssertNotNil(members)
    }
    
    func testReposiotry_whenAfterLoadMembersFromRemote_updateCache() {
        // given
        let expect = expectation(description: "리모트에서 멤버 로드 이후에 캐시 업데이트")
        
        self.mockRemote.register(key: "requestLoadMember") { Maybe<[Member]>.just([]) }
        self.mockLocal.called(key: "saveMembers") { _ in
            expect.fulfill()
        }
        // when
        let load = self.repository.requestLoadMembers(["uid:1", "uid:2"])
        let members = self.waitFirstElement(expect, for: load.asObservable())
        
        // then
        XCTAssertNotNil(members)
    }
}

extension RepositoryTests_Member {
    
    class DummyRepository: MemberRepository, MemberRepositoryDefImpleDependency {
        
        let memberRemote: MemberRemote
        let memberLocal: MemberLocalStorage
        let disposeBag: DisposeBag = .init()
        let fileHandleService: FileHandleService
        
        init(remote: MemberRemote, local: MemberLocalStorage, fileHandle: FileHandleService) {
            self.memberRemote = remote
            self.memberLocal = local
            self.fileHandleService = fileHandle
        }
    }
    
    class MockFileService: FileHandleService {
        
        var copyResultMocking: Result<Void, Error> = .success(())
        func copy(source: FilePath, to: FilePath) -> Maybe<Void> {
            return self.copyResultMocking.asMaybe()
        }
    }
}

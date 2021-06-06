//
//  MemberUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class MemberUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var store: SharedDataStoreServiceImple!
    var stubRepository: StubMemberRepository!
    var usecase: MemberUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubRepository = .init()
        self.store = .init()
        self.usecase = MemberUsecaseImple(memberRepository: self.stubRepository, sharedDataService: self.store)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubRepository = nil
        self.store = nil
        self.usecase = nil
        super.tearDown()
    }
}


extension MemberUsecaseTests {
    
    func testUsecase_updateUserIsOnlneStatus() {
        // given
        let expect = expectation(description: "유저 온라인 여부 업데이트")
        
        self.stubRepository.called(key: "requestUpdateUserPresence") { args in
            if let isOnline = args as? Bool, isOnline {
                expect.fulfill()
            }
        }
        
        
        // when
        self.usecase.updateUserIsOnline("some", isOnline: true)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
//    func testUsecase_loadNearbyUserPresences() {
//        // given
//        let expect = expectation(description: "주변에 존재하는 유저 조회")
//
//        self.stubRepository.register(key: "requestLoadNearbyUsers") {
//            return Maybe<[UserPresence]>.just([UserPresence(userID: "dummy", lastLocation: .init(lattitude: 0, longitude: 0, timeStamp: 0))])
//        }
//
//        // when
//        let requestLoad = self.usecase.loadNearbyUsers(at: .init(latt: 0, long: 0))
//        let presences = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
//
//        // then
//        XCTAssertEqual(presences?.count, 1)
//    }
    
    func testUsecase_whenLoadCurrentMemberShip_existOnSharedStore() {
        // given
        let expect = expectation(description: "공유 저장소에 멤버쉽 존재하는 경우 로드")
        self.store.save(.membership, MemberShip())
        
        // when
        let requestLoad = self.usecase.loadCurrentMembership()
        let membership = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(membership)
    }
    
    func testUsecase_whenLoadCurrentMemberShip_notExistOnSharedStore() {
        // given
        let expect = expectation(description: "공유 저장소에 멤버쉽 존재 안하는 경우 로드")
        self.store.save(.currentMember, Member(uid: "dummy"))
        self.stubRepository.register(key: "requestLoadMembership") {
            return Maybe<MemberShip>.just(.init())
        }
        
        // when
        let requestLoad = self.usecase.loadCurrentMembership()
        let membership = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(membership)
    }
    
    func testUsecase_observeCurrentMember() {
        // given
        let expect = expectation(description: "현재유저 옵저빙")
        
        // when
        let member = self.waitFirstElement(expect, for: self.usecase.currentMember.compactMap{ $0 }) {
            self.store.update(SharedDataKeys.currentMember.rawValue, value: Member(uid: "some"))
        }
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testUsecase_fetchCurrentMember() {
        // given
        var memner: Member?
        
        // when + then
        memner = self.usecase.fetchCurrentMember()
        XCTAssertNil(memner)
        
        self.store.update(SharedDataKeys.currentMember.rawValue, value: Member.init(uid: "some"))
        memner = self.usecase.fetchCurrentMember()
        XCTAssertNotNil(memner)
    }
}


extension MemberUsecaseTests {
    
    func testUsecase_whenEmptyUpdateParams_error() {
        // given
        let expect = expectation(description: "업데이트할 파라미터를 아무것도 입력하지 않았다면 에러")
        
        // when
        let error = self.waitError(expect, for: self.usecase.updateCurrent(memberID: "some", updateFields: [], with: nil))
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUscase_updateMemberWithOutUploadImage() {
        // given
        let expect = expectation(description: "프로필 이미지 업로드 없이 필드만 업데이트")
        
        self.stubRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let status = self.waitElements(expect, for: self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: nil))
        
        // then
        XCTAssertEqual(status.first, .finished)
    }
    
    func testUsecase_updateMemberWithUploadImage() {
        // given
        let expect = expectation(description: "새 프사와 함께 멤버 업데이트")
        expect.expectedFulfillmentCount = 3
        
        self.stubRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let image = ImageUploadReqParams.data(Data(), extension: "jpg")
        let requestUpload = self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: image)
        let status = self.waitElements(expect, for: requestUpload) {
            self.stubRepository.stubUploadStatus.onNext(.uploading(0.5))
            self.stubRepository.stubUploadStatus.onNext(.completed(.path("some")))
            self.stubRepository.stubUploadStatus.onCompleted()
        }
        
        // then
        XCTAssertEqual(status, [.pending, .updating(0.5), .finished])
    }
    
    // 프로필 업로드 성공해도 멤버데이터 업데이트 실패하면 실패처리
    func testUsecase_whenSuccesToUploadImageButUpdateFiledsFail_wholeProcessIsFail() {
        // given
        let expect = expectation(description: "프로필 이미지 업로드에 성공하더라도 필드업데이트 실패하면 전체 실패처리")
        
        self.stubRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.error(ApplicationErrors.invalid)
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let image = ImageUploadReqParams.data(Data(), extension: "jpg")
        let requestUpload = self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: image)
        let error = self.waitError(expect, for: requestUpload) {
            self.stubRepository.stubUploadStatus.onNext(.uploading(0.5))
            self.stubRepository.stubUploadStatus.onNext(.completed(.path("some")))
            self.stubRepository.stubUploadStatus.onCompleted()
        }
        
        // then
        XCTAssertNotNil(error)
    }
    
    // 프로필 업로드 실패 + 데이터 업로드
    func testUsecase_whenUploadImageFails_justUpdateMemberFields() {
        // given
        let expect = expectation(description: "멤버프로필 업로드에 실패해도 필드는 업데이트함")
        expect.expectedFulfillmentCount = 3
        
        self.stubRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let image = ImageUploadReqParams.data(Data(), extension: "jpg")
        let requestUpload = self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: image)
        let status = self.waitElements(expect, for: requestUpload) {
            self.stubRepository.stubUploadStatus.onNext(.uploading(0.5))
            self.stubRepository.stubUploadStatus.onError(ApplicationErrors.invalid)
        }
        
        // then
        XCTAssertEqual(status, [.pending, .updating(0.5), .finishedWithImageUploadFail(ApplicationErrors.invalid)])
    }
    
    func testUsecase_whenAfterUpdateMember_emitViaSharedStore() {
        // given
        let expect = expectation(description: "멤버 업데이트 이후에 새로운 유저값 share event 발생")
        
        self.stubRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let memberSource: Observable<Member> = self.store.observe(SharedDataKeys.currentMember.rawValue).compactMap{ $0 }
        let newMember = self.waitFirstElement(expect, for: memberSource) {
            let intro = MemberUpdateField.introduction("new")
            self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: nil)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertNotNil(newMember)
    }
}

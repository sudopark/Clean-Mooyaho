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
    var mockRepository: MockMemberRepository!
    var usecase: MemberUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.mockRepository = .init()
        self.store = .init()
        self.usecase = MemberUsecaseImple(memberRepository: self.mockRepository, sharedDataService: self.store)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockRepository = nil
        self.store = nil
        self.usecase = nil
        super.tearDown()
    }
}


extension MemberUsecaseTests {
    
    func testUsecase_updateUserIsOnlneStatus() {
        // given
        let expect = expectation(description: "유저 온라인 여부 업데이트")
        
        self.mockRepository.called(key: "requestUpdateUserPresence") { args in
            if let isOnline = args as? Bool, isOnline {
                expect.fulfill()
            }
        }
        
        
        // when
        self.usecase.updateUserIsOnline("some", deviceID: "dev_id", isOnline: true)
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testUsecase_updatePushToken() {
        // given
        let expect = expectation(description: "push token 업데이트")
        
        self.mockRepository.called(key: "requestUpdatePushToken") { _ in
            expect.fulfill()
        }
        
        // when
        self.usecase.updatePushToken("some", deviceID: "dev_id", newToken: "new_value")
        
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
        self.store.save(MemberShip.self, key: .membership, MemberShip())
        
        // when
        let requestLoad = self.usecase.loadCurrentMembership()
        let membership = self.waitFirstElement(expect, for: requestLoad.asObservable()) { }
        
        // then
        XCTAssertNotNil(membership)
    }
    
    func testUsecase_whenLoadCurrentMemberShip_notExistOnSharedStore() {
        // given
        let expect = expectation(description: "공유 저장소에 멤버쉽 존재 안하는 경우 로드")
        self.store.save(Member.self, key: .currentMember, Member(uid: "dummy"))
        self.mockRepository.register(key: "requestLoadMembership") {
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
            self.store.update(Member.self, key: SharedDataKeys.currentMember.rawValue, value: Member(uid: "some"))
        }
        
        // then
        XCTAssertNotNil(member)
    }
    
    func testUsecase_fetchCurrentMember() {
        // given
        var member: Member?
        
        // when + then
        member = self.usecase.fetchCurrentMember()
        XCTAssertNil(member)
        
        self.store.update(Member.self, key: SharedDataKeys.currentMember.rawValue, value: Member.init(uid: "some"))
        member = self.usecase.fetchCurrentMember()
        XCTAssertNotNil(member)
    }
    
    func testUsecase_reloadCurrentMember() {
        // given
        let expect = expectation(description: "현재 유저 리로드")
        self.store.updateAuth(.init(userID: "some"))
        
        self.mockRepository.register(type: Maybe<[Member]>.self, key: "requestLoadMembers") {
            return .just([Member(uid: "some", nickName: "new member", icon: nil)])
        }
        
        // when
        let loading = self.usecase.reloadCurrentMember()
        let member = self.waitFirstElement(expect, for: loading.asObservable())
        
        // then
        XCTAssertEqual(member?.nickName, "new member")
    }
    
    func testUsecase_whenReloadCurrentMemberWithoutSignIn_error() {
        // given
        let expect = expectation(description: "로그인 안한상태에서 현재 멤버 로드시 에러")
        self.store.clearAuth()
        
        self.mockRepository.register(type: Maybe<[Member]>.self, key: "requestLoadMembers") {
            return .just([Member(uid: "some", nickName: "new member", icon: nil)])
        }
        
        // when
        let loading = self.usecase.reloadCurrentMember()
        let error = self.waitError(expect, for: loading.asObservable())
        
        // then
        XCTAssertNotNil(error)
    }
    
    func testUsecase_whenAfterReloadCurrentMember_updateSharedStore() {
        // given
        let expect = expectation(description: "현재 멤버 reload 시에 스토어 업데이트")
        self.store.updateAuth(.init(userID: "some"))
        self.mockRepository.register(type: Maybe<[Member]>.self, key: "requestLoadMembers") {
            return .just([Member(uid: "some", nickName: "new member", icon: nil)])
        }
        
        // when
        let currentMemberSource = self.store.observe(Member.self, key: SharedDataKeys.currentMember.rawValue)
        let membersMapSource = self.store.observe([String: Member].self, key: SharedDataKeys.memberMap.rawValue)
        let sharedEventSource = Observable.combineLatest(currentMemberSource, membersMapSource)
        let pair = self.waitFirstElement(expect, for: sharedEventSource) {
            self.usecase.reloadCurrentMember()
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertEqual(pair?.0?.nickName, "new member")
        XCTAssertEqual(pair?.1?["some"]?.nickName, "new member")
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
        
        self.mockRepository.register(key: "requestUpdateMemberProfileFields") {
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
        
        self.mockRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let image = ImageUploadReqParams.data(Data(), extension: "jpg", size: .init(100, 100))
        let requestUpload = self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: image)
        let status = self.waitElements(expect, for: requestUpload) {
            self.mockRepository.uploadStatus.onNext(.uploading(0.5))
            let thumb = MemberThumbnail.imageSource(.init(path: "some", size: .init(100, 100)))
            self.mockRepository.uploadStatus.onNext(.completed(thumb))
            self.mockRepository.uploadStatus.onCompleted()
        }
        
        // then
        XCTAssertEqual(status, [.pending, .updating(0.5), .finished])
    }
    
    // 프로필 업로드 성공해도 멤버데이터 업데이트 실패하면 실패처리
    func testUsecase_whenSuccesToUploadImageButUpdateFiledsFail_wholeProcessIsFail() {
        // given
        let expect = expectation(description: "프로필 이미지 업로드에 성공하더라도 필드업데이트 실패하면 전체 실패처리")
        
        self.mockRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.error(ApplicationErrors.invalid)
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let image = ImageUploadReqParams.data(Data(), extension: "jpg", size: .init(100, 100))
        let requestUpload = self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: image)
        let error = self.waitError(expect, for: requestUpload) {
            self.mockRepository.uploadStatus.onNext(.uploading(0.5))
            let thumb = MemberThumbnail.imageSource(.init(path: "some", size: .init(100, 100)))
            self.mockRepository.uploadStatus.onNext(.completed(thumb))
            self.mockRepository.uploadStatus.onCompleted()
        }
        
        // then
        XCTAssertNotNil(error)
    }
    
    // 프로필 업로드 실패 + 데이터 업로드
    func testUsecase_whenUploadImageFails_justUpdateMemberFields() {
        // given
        let expect = expectation(description: "멤버프로필 업로드에 실패해도 필드는 업데이트함")
        expect.expectedFulfillmentCount = 3
        
        self.mockRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let intro = MemberUpdateField.introduction("new")
        let image = ImageUploadReqParams.data(Data(), extension: "jpg", size: .init(100, 100))
        let requestUpload = self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: image)
        let status = self.waitElements(expect, for: requestUpload) {
            self.mockRepository.uploadStatus.onNext(.uploading(0.5))
            self.mockRepository.uploadStatus.onError(ApplicationErrors.invalid)
        }
        
        // then
        XCTAssertEqual(status, [.pending, .updating(0.5), .finishedWithImageUploadFail(ApplicationErrors.invalid)])
    }
    
    func testUsecase_whenAfterUpdateMember_emitViaSharedStore() {
        // given
        let expect = expectation(description: "멤버 업데이트 이후에 새로운 유저값 share event 발생")
        
        self.mockRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let memberSource = self.store.observe(Member.self, key: SharedDataKeys.currentMember.rawValue).compactMap{ $0 }
        let newMember = self.waitFirstElement(expect, for: memberSource) {
            let intro = MemberUpdateField.introduction("new")
            self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: nil)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertNotNil(newMember)
    }
    
    func testUsecase_whenAfterUpdateMember_emitViaSharedStoreMemberMapUpdated() {
        // given
        let expect = expectation(description: "멤버 업데이트 이후에 새로운 memberMap share event로 발생")
        
        self.mockRepository.register(key: "requestUpdateMemberProfileFields") {
            return Maybe<Member>.just(.init(uid: "some"))
        }
        
        // when
        let memberMapSource = self.store.observe([String: Member].self, key: SharedDataKeys.memberMap.rawValue)
        let memberMap = self.waitFirstElement(expect, for: memberMapSource) {
            let intro = MemberUpdateField.introduction("new")
            self.usecase.updateCurrent(memberID: "some", updateFields: [intro], with: nil)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        let member = memberMap?["some"]
        XCTAssertNotNil(member)
    }
}


extension MemberUsecaseTests {
    
    func testUsecase_loadMembers() {
        // given
        let expect = expectation(description: "멤버 정보 로드")
        self.mockRepository.register(key: "requestLoadMembers") {
            return Maybe<[Member]>.just([Member(uid: "uid:2", nickName: "remote")])
        }
        
        // when
        let loading = self.usecase.loadMembers(["uid:2"]).asObservable()
        let members = self.waitFirstElement(expect, for: loading)
        
        // then
        XCTAssertEqual(members?.count, 1)
    }
    
    func testUsecase_whenAfterLoadMembers_updateOnShareStore() {
        // given
        let expect = expectation(description: "멤버 로드 이후에 shared store에 업데이트")
        self.mockRepository.register(key: "requestLoadMembers") {
            return Maybe<[Member]>.just([Member(uid: "uid:2", nickName: "remote")])
        }
        
        // when
        let key = SharedDataKeys.memberMap.rawValue
        let memberSource = self.store.observe([String: Member].self, key: key)
            .compactMap{ $0?["uid:2"] }
        let updatedMember = self.waitFirstElement(expect, for: memberSource) {
            self.usecase.loadMembers(["uid:2"])
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertNotNil(updatedMember)
    }
    
    func testUsecase_subscribeMembersInfo_withExistingCaches() {
        // given
        let expect = expectation(description: "캐시에 존재하는 정보와 함께 멤버정보 구독")
        self.mockRepository.register(key: "fetchMembers") { Maybe<[Member]>.just([Member(uid: "uid:1")]) }
        
        // when
        let memberMap = self.waitFirstElement(expect, for: self.usecase.members(for: ["uid:1"]))
        
        // then
        XCTAssertEqual(memberMap?.count, 1)
    }
    
    func testUsecase_subscribeMembersInfo_withExistingCaches_withLoadMembersFromRemote() {
        // given
        let expect = expectation(description: "멤버 로드시에 캐시에도 없는 유저는 리모트에서 불러옴")
        self.mockRepository.register(key: "fetchMembers") { Maybe<[Member]>.just([Member(uid: "uid:1")]) }
        self.mockRepository.register(key: "requestLoadMembers") { Maybe<[Member]>.just([Member(uid: "uid:2")]) }
        
        // when
        let memberMap = self.waitFirstElement(expect, for: self.usecase.members(for: ["uid:1", "uid:2"]))
        
        // then
        XCTAssertEqual(memberMap?.count, 2)
    }
    
    func testUsecase_refreshMembers() {
        // given
        let expect = expectation(description: "member 정보 업데이트")
        self.mockRepository.register(key: "fetchMembers") { Maybe<[Member]>.just([]) }
        self.mockRepository.register(key: "requestLoadMembers") {
            return Maybe<[Member]>.just((0..<3).map{ Member(uid: "uid:\($0)") })
        }
        
        // when
        let ids = (0..<3).map{ "uid:\($0)" }
        let updatedmembers = self.usecase.members(for: ids)
        let members = self.waitFirstElement(expect, for: updatedmembers, skip: 1) {
            self.usecase.refreshMembers(ids)
        }
        
        // then
        XCTAssertEqual(members?.count, 3)
    }
}

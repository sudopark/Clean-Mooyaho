//
//  LocalStorageTests+Auth&Member.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

@testable import DataStore


class LocalStorageTests_AuthAndMember: BaseLocalStorageTests {
    
    private var currentMemberID: String {
        return "dummy_member"
    }
    
    private func dummyMember(for uid: String) -> Member {
        var member = Member(uid: uid,
                            nickName: "dummy_nickname",
                            icon: .imageSource(.init(path: "image_path", size: .init(0, 0))))
        member.introduction = "hello world"
        return member
    }
}


extension LocalStorageTests_AuthAndMember {
    
    func testStorage_saveAndLoadCurrentMember() {
        // given
        let expect = expectation(description: "현재 memeber 정보 저장 및 로드")
        
        let auth = Auth(userID: self.currentMemberID)
        let member = self.dummyMember(for: self.currentMemberID)
        
        // when
        let saveAuth = self.local.saveSignedIn(auth: auth)
        let saveMember = self.local.saveSignedIn(member: member)
        let fetchMember = self.local.fetchCurrentMember()
        
        let saveAndLoad = saveAuth.flatMap{ _ in saveMember }.flatMap{ _ in fetchMember }
        let loadedMember = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(member.uid, loadedMember?.uid)
        XCTAssertEqual(member.nickName, loadedMember?.nickName)
        XCTAssertEqual(member.introduction, loadedMember?.introduction)
        XCTAssertEqual(member.icon, loadedMember?.icon)
    }
    
    func testStorage_updateMember() {
        // given
        let expect = expectation(description: "저장된 멤버 업데이트")
        let oldMember = self.dummyMember(for: self.currentMemberID)
        var newMember = oldMember
        newMember.icon = .emoji("🎒")
        newMember.nickName = "new nick"
        newMember.introduction = "new hello world!"
        
        // when
        let saveOldMember = self.local.saveMember(oldMember)
        let updateMember = self.local.updateCurrentMember(newMember).delay(.milliseconds(100), scheduler: MainScheduler.instance)
        let updateAndLoad = saveOldMember.flatMap{ _ in updateMember }.flatMap{ _ in self.local.fetchMember(for: self.currentMemberID) }
        let loadedMember = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedMember?.uid, self.currentMemberID)
        XCTAssertEqual(loadedMember?.nickName, "new nick")
        XCTAssertEqual(loadedMember?.introduction, "new hello world!")
        XCTAssertEqual(loadedMember?.icon, .emoji("🎒"))
    }
    
    func testStorage_saveMembersAndLoad() {
        // given
        let expect = expectation(description: "멤버정보 복수로 저장하고 로드")
        
        let members = (0..<10).map{ int -> Member in
            let icon: MemberThumbnail? = int % 2 == 0 ? .emoji("👻") : nil
            return Member(uid: "uid:\(int)", nickName: "nick:\(int)", icon: icon)
        }
        
        // when
        let ids = (0..<100).map{ "uid:\($0)" }
        let saveMembers = self.local.saveMembers(members)
        let loadMembers = self.local.fetchMembers(ids)
        let saveAndLoad = saveMembers.flatMap{ _ in loadMembers }
            
        let loadedMembers = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedMembers?.map{ $0.uid }, Array(ids[0..<10]))
    }
    
    func testStorage_updateWhenThumbnailNotExists_saveNewThumbnail() {
        // given
        let expect = expectation(description: "섬네일이 없는상태에서 섬네일 저장")
        let memberWithoutThumbnail = Member(uid: "some", nickName: "name", icon: nil)
        
        // when
        let saveMember = self.local.saveSignedIn(member: memberWithoutThumbnail)
        let memberWithThumbnail = memberWithoutThumbnail |> \.icon .~ .emoji("💩")
        let updateMember = self.local.updateCurrentMember(memberWithThumbnail)
        let loadMember = self.local.fetchMember(for: "some")
        let saveUpdateAndLoad = saveMember.flatMap { updateMember }.flatMap { loadMember }
        let member = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(member?.nickName, "name")
        XCTAssertEqual(member?.icon?.emoji, "💩")
    }
    
    func testStorage_updateWhenThumbnailExists_deleteThumbnailWithUpdating() {
        // given
        let expect = expectation(description: "섬네일 있는상태에서 아이콘 삭제 업데이트")
        let memberWithThumbnail = Member(uid: "some", nickName: "name", icon: .emoji("🎃"))
        
        // when
        let saveMember = self.local.saveSignedIn(member: memberWithThumbnail)
        let memberWithoutThumbnail = memberWithThumbnail |> \.icon .~ nil
        let updateMember = self.local.updateCurrentMember(memberWithoutThumbnail)
        let loadMember = self.local.fetchMember(for: "some")
        let saveUpdateAndLoad = saveMember.flatMap { updateMember }.flatMap { loadMember }
        let member = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(member?.nickName, "name")
        XCTAssertEqual(member?.icon?.emoji, nil)
    }
}

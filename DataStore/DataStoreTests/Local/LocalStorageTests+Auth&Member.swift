//
//  LocalStorageTests+Auth&Member.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

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
        
        let didSavedAuthData = self.mockEncrytedStorage.didSavedValue as? Data
        let didSavedAuth = didSavedAuthData.flatMap { try? JSONDecoder().decode(Auth.self, from: $0) }
        XCTAssertEqual(didSavedAuth?.isSignIn, true)
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
}

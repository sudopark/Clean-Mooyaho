//
//  LocalStorageTests+Hooray.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/08/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_Hooray: BaseLocalStorageTests { }


extension LocalStorageTests_Hooray {
    
    private func dummyHooray(_ int: Int) -> Hooray {
        
        return Hooray(uid: "hid:\(int)", placeID: "pid", publisherID: "pub_id", hoorayKeyword: .default,
                      message: "msg", tags: ["t1", "t2"], image: .init(path: "path", size: .init(0, 0)),
                      location: .init(latt: 100, long: 300.2), timestamp: TimeInterval(int) + 100,
                      spreadDistance: 100.2, aliveDuration: 200.3)
    }
    
    func testStorage_loadLatestHoorayForMember() {
        // given
        let expect = expectation(description: "유저의 가장 최근 후레이 3개 조회")
        
        // when
        let hoorays = (0..<10).map{ self.dummyHooray($0) }
        let save = self.local.saveHoorays(hoorays)
        let load = self.local.fetchLatestHoorays(for: "pub_id", limit: 3)
        let saveAndLoad = save.flatMap{ _ in load }
        let loadedHoorays = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedHoorays?.count, 3)
        let timeStamps = loadedHoorays?.map{ $0.timeStamp }
        XCTAssertEqual(timeStamps, [109, 108, 107])
    }
    
    func testStorage_saveAndLoadHooray() {
        // given
        let expect = expectation(description: "hooray 저장 이후에 로드")
        
        // when
        let hoorays = (0..<10).map{ self.dummyHooray($0) }
        let save = self.local.saveHoorays(hoorays)
        let load = self.local.fetchHoorays(hoorays.map{ $0.uid })
        let saveAndLoad = save.flatMap{ _ in load }
        let loadedHoorays = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedHoorays?.count, 10)
        XCTAssertEqual(loadedHoorays?.first?.uid, "hid:0")
        XCTAssertEqual(loadedHoorays?.first?.placeID, "pid")
        XCTAssertEqual(loadedHoorays?.first?.publisherID, "pub_id")
        XCTAssertEqual(loadedHoorays?.first?.hoorayKeyword.text, Hooray.Keyword.default.text)
        XCTAssertEqual(loadedHoorays?.first?.message, "msg")
        XCTAssertEqual(loadedHoorays?.first?.tags, ["t1", "t2"])
        XCTAssertEqual(loadedHoorays?.first?.image, .init(path: "path", size: .init(0, 0)))
        XCTAssertEqual(loadedHoorays?.first?.location, .init(latt: 100, long: 300.2))
        XCTAssertEqual(loadedHoorays?.first?.timeStamp, 100)
        XCTAssertEqual(loadedHoorays?.first?.spreadDistance, 100.2)
        XCTAssertEqual(loadedHoorays?.first?.aliveDuration, 200.3)
    }
    
    private func hoorayDetail(for int: Int) -> HoorayDetail {
        let hooray = self.dummyHooray(int)
        let acks = (0..<10).map{ HoorayAckInfo(hoorayID: hooray.uid, ackUserID: "u:\($0)", ackAt: 100) }
        let reactions = (0..<10).map{ HoorayReaction(hoorayID: hooray.uid, reactionID: "r:\(hooray.uid)-\($0))",
                                                     reactMemberID: "r\($0)", icon: .emoji("😨"),
                                                     reactAt: 100) }
        return HoorayDetail(info: hooray, acks: acks, reactions: reactions)
    }
    
    func testLocalStorage_saveAndLoadHoorayDetail() {
        // given
        let expect = expectation(description: "hooray detail 저장하고난뒤 로드")
        let (detail0, detail1) = (self.hoorayDetail(for: 0), self.hoorayDetail(for: 1))
        
        // when
        let saveBoth = self.local.saveHoorayDetail(detail0)
            .flatMap{ _ in self.local.saveHoorayDetail(detail1) }
        let load0 = self.local.fetchHoorayDetail(detail0.hoorayInfo.uid)
        let saveAndLoad = saveBoth.flatMap{ _ in load0 }
        let loadedDetail0 = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedDetail0?.hoorayInfo.uid, detail0.hoorayInfo.uid)
        XCTAssertEqual(loadedDetail0?.acks.count, detail0.acks.count)
        XCTAssertEqual(loadedDetail0?.reactions.map{ $0.reactionID }, detail0.reactions.map{ $0.reactionID })
    }
}




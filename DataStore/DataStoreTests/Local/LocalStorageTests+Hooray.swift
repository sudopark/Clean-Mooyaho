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
        
        return Hooray(uid: "hid:\(int)", placeID: "pid", publisherID: "pub_id", hoorayKeyword: "kwd",
                      message: "msg", tags: ["t1", "t2"], image: .path("path"),
                      location: .init(latt: 100, long: 300.2), timestamp: 100,
                      reactions: [], spreadDistance: 100.2, aliveDuration: 200.3)
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
        XCTAssertEqual(loadedHoorays?.first?.hoorayKeyword, "kwd")
        XCTAssertEqual(loadedHoorays?.first?.message, "msg")
        XCTAssertEqual(loadedHoorays?.first?.tags, ["t1", "t2"])
        XCTAssertEqual(loadedHoorays?.first?.image, .path("path"))
        XCTAssertEqual(loadedHoorays?.first?.location, .init(latt: 100, long: 300.2))
        XCTAssertEqual(loadedHoorays?.first?.timeStamp, 100)
        XCTAssertEqual(loadedHoorays?.first?.reactions, [])
        XCTAssertEqual(loadedHoorays?.first?.spreadDistance, 100.2)
        XCTAssertEqual(loadedHoorays?.first?.aliveDuration, 200.3)
    }
   
    func testLocalStorage_saveAndLoadHooray_whichHasReactions() {
        // given
        let expect = expectation(description: "ack userInfo와 함께 hooray 저장")
        
        var hoorays = (0..<10).map{ self.dummyHooray($0) }
        hoorays = hoorays.map {
            var h = $0
            let acks = (0..<10).map{ HoorayAckInfo(ackUserID: "uid:\($0)", ackAt: TimeInterval($0)) }
            h.ackUserIDs = Set(acks)
            return h
        }
        
        // when
        let save = self.local.saveHoorays(hoorays)
        let load = self.local.fetchHoorays(hoorays.map{ $0.uid })
        let saveAndLoad = save.flatMap{ _ in load }
        let loadedHoorays = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let ackCounts = loadedHoorays?.map{ $0.ackUserIDs.count }
        XCTAssertEqual(ackCounts, Array(repeating: 10, count: 10))
        
        let lastAck = loadedHoorays?.first?.ackUserIDs.sorted(by:{ $0.ackAt < $1.ackAt }).last
        XCTAssertEqual(lastAck?.ackUserID, "uid:9")
        XCTAssertEqual(lastAck?.ackAt, 9)
    }
    
    func testLocalStorage_saveAndLoadHooray_whichHasAckUsers() {
        // given
        let expect = expectation(description: "ack userInfo + reactioninfo와 함께 hooray 저장")
        
        var hoorays = (0..<10).map{ self.dummyHooray($0) }
        hoorays = hoorays.map {
            var h = $0
            let acks = (0..<10).map{ HoorayAckInfo(ackUserID: "uid:\($0)", ackAt: TimeInterval($0)) }
            h.ackUserIDs = Set(acks)
            let reactions = (0..<10).map{
                HoorayReaction.ReactionInfo(reactionID: "r:\($0)-\(h.uid)",
                                            reactMemberID: "uid:\($0)",
                                            icon: .emoji("😲"), reactAt: TimeInterval($0))
            }
            h.reactions = Set(reactions)
            return h
        }
        
        // when
        let save = self.local.saveHoorays(hoorays)
        let load = self.local.fetchHoorays(hoorays.map{ $0.uid })
        let saveAndLoad = save.flatMap{ _ in load }
        let loadedHoorays = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let reactionCounts = loadedHoorays?.map{ $0.reactions.count }
        XCTAssertEqual(reactionCounts, Array(repeating: 10, count: 10))
        
        let lastReaction = loadedHoorays?.first?.reactions.sorted(by:{ $0.reactAt < $1.reactAt }).last
        XCTAssertEqual(lastReaction?.reactionID, "r:9-hid:0")
        XCTAssertEqual(lastReaction?.reactMemberID, "uid:9")
        XCTAssertEqual(lastReaction?.icon, .emoji("😲"))
        XCTAssertEqual(lastReaction?.reactAt, 9)
    }
}




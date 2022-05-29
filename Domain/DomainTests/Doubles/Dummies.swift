//
//  Dummies.swift
//  DomainTests
//
//  Created by sudo.park on 2021/06/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Prelude
import Optics

@testable import Domain


extension SigninResult {
    
    static func dummy(_ uuid: String) -> Self {
        let auth = Auth(userID: uuid)
        return .init(auth: auth, member: .init(uid: uuid))
    }
}

extension ReadLink {
    
    static func dummy(_ int: Int, parent: Int? = nil) -> ReadLink {
        return ReadLink(uid: "uid:\(int)",
                        link: "link:\(int)",
                        createAt: .now() + TimeStamp(int),
                        lastUpdated: .now() + TimeStamp(int))
    }
}

extension ReadCollection {
    
    static func dummy(_ int: Int, parent: Int? = nil) -> ReadCollection {
        return ReadCollection(uid: "uid:\(int)",
                              name: "c:\(int)",
                              createdAt: .now() + TimeStamp(int),
                              lastUpdated: .now() + TimeStamp(int))
    }
}


extension LinkPreview {
    
    static func dummy(_ int: Int) -> LinkPreview {
        return LinkPreview(title: "t:\(int)", description: "des:\(int)",
                           mainImageURL: "url", iconURL: nil)
    }
}

extension ItemCategory {
    
    static func dummy(_ int: Int) -> ItemCategory {
        return ItemCategory(uid: "cate:\(int)", name: "name:\(int)",
                            colorCode: "color:\(int)", createdAt: .now())
    }
}

extension ReadRemindMessage {
    
    static func dummy(_ int: Int) -> ReadRemindMessage {
        return ReadRemindMessage(itemID: "c:\(int)", scheduledTime: .now() + 1000)
    }
}

extension ReadLinkMemo {
    
    static func dummyID(_ id: String) -> ReadLinkMemo {
        return .init(itemID: id)
    }
}


extension SharedReadCollection {
    
    static func dummy(_ int: Int) -> SharedReadCollection {
        return SharedReadCollection(shareID: "s:\(int)",
                                    uid: "sid:\(int)",
                                    name: "share:\(int)",
                                    createdAt: TimeInterval(int),
                                    lastUpdated: TimeInterval(int))
    }
}

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

extension PlaceSnippet {
    
    static func dummy(_ int: Int) -> PlaceSnippet {
        return PlaceSnippet(placeID: "uid:\(int)",
                            title: "title:\(int)",
                            latt: 0, long: 0)
    }
}

extension Place {
    
    static func dummy(_ int: Int) -> Place {
        return Place(uid: "uid:\(int)", title: "title:\(int)",
                     coordinate: .init(latt: 0, long: 0),
                     address: "address:\(int)",
                     categoryTags: [],
                     reporterID: "reporter:\(int)",
                     infoProvider: .userDefine,
                     createdAt: .now(),
                     pickCount: int,
                     lastPickedAt: .now())
    }
}


extension UserLocation {
    
    static func dummy(_ int: Int = 0) -> Self {
        return .init(userID: "uid:\(int)",
                     lastLocation: .init(lattitude: Double(int),
                                         longitude: Double(int),
                                         timeStamp: Double(int)))
    }
}


extension SearchingPlace {
    
    static func dummy(_ int: Int) -> SearchingPlace {
        return SearchingPlace(uid: "uid:\(int)",
                              title: "title:\(int)",
                              coordinate: .init(latt: 0, long: 0),
                              address: "address:\(int)",
                              categories: [])
    }
}


extension Hooray {
    
    static func dummy(_ int: Int) -> Hooray {
        return Hooray(uid: "uid:\(int)",
                      placeID: "place:\(int)",
                      publisherID: "pub:\(int)",
                      hoorayKeyword: .default,
                      message: "hi",
                      location: .init(latt: 0, long: 0),
                      timestamp: 0,
                      spreadDistance: 100, aliveDuration: 100)
    }
}

extension HoorayDetail {
    
    static func dummy(_ int: Int) -> HoorayDetail {
        return HoorayDetail(info: .dummy(int),
                            acks: [],
                            reactions: [])
    }
}


extension NewHoorayMessage {
    
    static func dummy(_ int: Int) -> NewHoorayMessage {
        return .init(hoorayID: "id:\(int)", publisherID: "pub:\(int)", publishedAt: 0, placeID: "place", location: .init(latt: 0, long: 0), spreadDistance: 10, aliveDuration: 10)
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
        return ItemCategory(uid: "cate:\(int)", name: "name:\(int)", colorCode: "color:\(int)")
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

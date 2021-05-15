//
//  Dummies.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

@testable import Domain


extension SigninResult {
    
    static func dummy(_ uuid: String) -> Self {
        return .init(auth: Auth(userID: uuid), member: .init(uid: uuid))
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
                      location: .init(latt: 0, long: 0),
                      timestamp: 0,
                      ackUserIDs: [],
                      reactions: [],
                      spreadDistance: 100, aliveDuration: 100)
    }
}


extension NewHoorayMessage {
    
    static func dummy(_ int: Int) -> NewHoorayMessage {
        return .init(hoorayID: "id:\(int)", publisherID: "pub:\(int)", publisherNickName: "pub_nick:\(int)", publishedAt: 0, placeID: "place", location: .init(latt: 0, long: 0), spreadDistance: 10, aliveDuration: 10)
    }
}

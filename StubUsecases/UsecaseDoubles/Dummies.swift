//
//  Dummies.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/06/06.
//

import Foundation

import Domain


extension SigninResult {
    
    public static func dummy(_ uuid: String) -> Self {
        return .init(auth: Auth(userID: uuid), member: .init(uid: uuid))
    }
}

extension PlaceSnippet {
    
    public static func dummy(_ int: Int) -> PlaceSnippet {
        return PlaceSnippet(placeID: "uid:\(int)",
                            title: "title:\(int)",
                            latt: 0, long: 0)
    }
}

extension Place {
    
    public static func dummy(_ int: Int) -> Place {
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
    
    public static func dummy(_ int: Int = 0) -> Self {
        return .init(userID: "uid:\(int)",
                     lastLocation: .init(lattitude: Double(int),
                                         longitude: Double(int),
                                         timeStamp: Double(int)))
    }
}


extension SearchingPlace {
    
    public static func dummy(_ int: Int) -> SearchingPlace {
        return SearchingPlace(uid: "uid:\(int)",
                              title: "title:\(int)",
                              coordinate: .init(latt: 0, long: 0),
                              address: "address:\(int)",
                              categories: [],
                              link: "some:\(int)")
    }
}


extension Hooray {
    
    public static func dummy(_ int: Int) -> Hooray {
        return Hooray(uid: "uid:\(int)",
                      placeID: "place:\(int)",
                      publisherID: "pub:\(int)",
                      hoorayKeyword: "some",
                      message: "hi",
                      location: .init(latt: 0, long: 0),
                      timestamp: 0,
                      ackUserIDs: [],
                      reactions: [],
                      spreadDistance: 100, aliveDuration: 100)
    }
}


extension NewHoorayMessage {
    
    public static func dummy(_ int: Int) -> NewHoorayMessage {
        return .init(hoorayID: "id:\(int)", publisherID: "pub:\(int)", publishedAt: 0, placeID: "place", location: .init(latt: 0, long: 0), spreadDistance: 10, aliveDuration: 10)
    }
}

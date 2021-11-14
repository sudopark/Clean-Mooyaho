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
                            latt: Double(int), long: Double(int))
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
                      hoorayKeyword: .default,
                      message: "hi",
                      tags: ["t1"],
                      image: .init(path: "path", size: nil),
                      location: .init(latt: 0, long: 0),
                      timestamp: 0,
                      spreadDistance: 100, aliveDuration: 100)
    }
}

extension HoorayDetail {
    
    public static func dummy(_ int: Int,
                             acks: [HoorayAckInfo] = [],
                             reactions: [HoorayReaction] = []) -> HoorayDetail {
        return HoorayDetail(info: .dummy(int), acks: acks, reactions: reactions)
    }
}


extension NewHoorayMessage {
    
    public static func dummy(_ int: Int) -> NewHoorayMessage {
        return .init(hoorayID: "id:\(int)", publisherID: "pub:\(int)", publishedAt: 0, placeID: "place", location: .init(latt: 0, long: 0), spreadDistance: 10, aliveDuration: 10)
    }
}


extension ReadCollection {
    
    public static func dummy(_ int: Int) -> ReadCollection {
        return .init(uid: "c:\(int)", name: "collection:\(int)",
                     createdAt: int.asTimeStamp(), lastUpdated: int.asTimeStamp())
    }
}

extension ReadLink {
    
    public static func dummy(_ int: Int) -> ReadLink {
        return .init(uid: "l:\(int)", link: "link:\(int)", createAt: int.asTimeStamp(), lastUpdated: int.asTimeStamp())
    }
}


extension LinkPreview {
    
    public static func dummy(_ int: Int) -> LinkPreview {
        return LinkPreview(title: "t:\(int)", description: "des:\(int)",
                           mainImageURL: "url", iconURL: nil)
    }
}


extension ItemCategory {
    
    public static func dummy(_ int: Int) -> ItemCategory {
        
        return  ItemCategory(uid: "c:\(int)", name: "n:\(int)", colorCode: "code:\(int)")
    }
}


extension SuggestCategory {
    
    public static func dummy(_ int: Int) -> SuggestCategory {
        return .init(ownerID: "o:\(int)", category: .dummy(int), lastUpdated: .now() + Double(int))
    }
}

extension SuggestCategoryCollection {
    
    public static func dummy(_ query: String, page: Int?, nextCursor: String?) -> SuggestCategoryCollection {
        let page = page ?? 0
        let range = page*10..<page*10+10
        let categories = range.map { SuggestCategory.dummy($0) }
        return .init(query: query, categories: categories, cursor: nextCursor)
    }
}


extension SharedReadCollection {
    
    public static func dummy(_ int: Int) -> SharedReadCollection {
        return SharedReadCollection(uid: "sid:\(int)",
                                    name: "share:\(int)",
                                    createdAt: TimeInterval(int),
                                    lastUpdated: TimeInterval(int))
    }
}

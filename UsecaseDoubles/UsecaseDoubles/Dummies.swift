//
//  Dummies.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/06/06.
//

import Foundation

import Prelude
import Optics

import Domain


extension SigninResult {
    
    public static func dummy(_ uuid: String) -> Self {
        return .init(auth: Auth(userID: uuid), member: .init(uid: uuid))
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
        
        return  ItemCategory(uid: "c:\(int)", name: "n:\(int)",
                             colorCode: "code:\(int)", createdAt: .now() + int.asTimeStamp())
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
        return SharedReadCollection(shareID: "s:\(int)",
                                    uid: "c:\(int)",
                                    name: "share:\(int)",
                                    createdAt: TimeInterval(int),
                                    lastUpdated: TimeInterval(int))
            |> \.ownerID .~ "some:\(int)"
    }
    
    public static func dummySubCollection(_ int: Int) -> SharedReadCollection {
        return .init(subCollection: .dummy(int))
    }
}

extension SharedReadLink {
    
    public static func dummy(_ int: Int) -> SharedReadLink {
        return SharedReadLink(link: .dummy(int))
    }
}


extension SearchReadItemIndex {
    
    public static func dummy(_ index: Int) -> SearchReadItemIndex {
        return .init(itemID: "id:\(index)", displayName: "name:\(index)")
    }
}

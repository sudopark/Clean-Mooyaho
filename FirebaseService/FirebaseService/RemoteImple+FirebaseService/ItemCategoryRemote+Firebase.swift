//
//  ItemCategoryRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/10/10.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestSuggestCategories(_ name: String,
                                         cursor: String?) -> Maybe<SuggestCategoryCollection> {
        return .empty()
    }
    
    public func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        return .empty()
    }
}

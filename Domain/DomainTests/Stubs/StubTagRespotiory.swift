//
//  StubTagRespotiory.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain

class StubTagRepository: TagRespository, Stubbable {
    
    func makeNew(tag: Tag) -> Maybe<Void> {
        return self.resolve(key: "makeNew:tag") ?? .empty()
    }
    
    func select(tag: Tag) -> Maybe<Void> {
        return self.resolve(key: "select:tag") ?? .empty()
    }
    
    func removeRecentSelect(tag: Tag) -> Maybe<Void> {
        return self.resolve(key: "removeRecentSelect:tag") ?? .empty()
    }
    
    func fetchRecentTags(type: Tag.TagType, query: String) -> Maybe<[Tag]> {
        return self.resolve(key: "fetchRecentTags:\(type)-\(query)") ?? .empty()
    }
    
    func userCommentStubKey(query: String, cursor: String? = nil) -> String {
        return "requestLoadPlaceCommnetTags:\(query)-\(String(describing: cursor))"
    }
    
    func userFeelingStubKey(query: String, cursor: String? = nil) -> String {
        return "requestLoadUserFeelingTags:\(query)-\(String(describing: cursor))"
    }
    
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Observable<SuggestTagResultCollection> {
        
        let key = self.userCommentStubKey(query: keyword, cursor: cursor)
        return self.resolve(key: key) ?? .empty()
    }
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Observable<SuggestTagResultCollection> {
        let key = self.userFeelingStubKey(query: keyword, cursor: cursor)
        return self.resolve(key: key) ?? .empty()
    }
}

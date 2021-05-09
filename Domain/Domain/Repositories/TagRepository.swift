//
//  TagRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/05/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

public protocol TagRespository {
    
    func select(tag: Tag) -> Maybe<Void>
    
    func makeNew(tag: Tag) -> Maybe<Void>
    
    func removeRecentSelect(tag: Tag) -> Maybe<Void>
    
    func fetchRecentTags(type: Tag.TagType, query: String) -> Maybe<[Tag]>
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Observable<SuggestTagResultCollection>
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Observable<SuggestTagResultCollection>
}


extension TagRespository {
    
    public func fetchRecentPlaceCommentTag() -> Maybe<[Tag]> {
        return self.fetchRecentTags(type: .userComments, query: "")
    }
    
    public func fetchRecentUserFeelingCommentTag(query: String) -> Maybe<[Tag]> {
        return self.fetchRecentTags(type: .userFeeling, query: query)
    }
}

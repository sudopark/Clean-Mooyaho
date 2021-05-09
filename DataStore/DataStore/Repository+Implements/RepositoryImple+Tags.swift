//
//  RepositoryImple+Tags.swift
//  DataStore
//
//  Created by sudo.park on 2021/05/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol TagRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var remote: Remote { get }
    var local: LocalStorage { get }
}


extension TagRespository where Self: TagRepositoryDefImpleDependency {
    
    public func select(tag: Tag) -> Maybe<Void> {
        return self.local.updateRecentSelect(tag: tag)
    }
    
    public func makeNew(tag: Tag) -> Maybe<Void> {
        
        let thenUpdate: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.select(tag: tag)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.remote.requestRegisterTag(tag)
            .do(onNext: thenUpdate)
    }
    
    public func removeRecentSelect(tag: Tag) -> Maybe<Void> {
        return self.local.removeRecentSelect(tag: tag)
    }
    
    public func fetchRecentTags(type: Tag.TagType, query: String) -> Maybe<[Tag]> {
        return self.local.fetchRecentSelectTags(type, query: query)
    }
    
    public func requestLoadPlaceCommnetTags(_ keyword: String,
                                            cursor: String?) -> Observable<SuggestTagResultCollection> {

        return loadTagsWithCacheIfNeed(.userComments, keyword: keyword, cursor: cursor, cacheResult: true)
    }
    
    public func requestLoadUserFeelingTags(_ keyword: String,
                                           cursor: String?) -> Observable<SuggestTagResultCollection> {
        return loadTagsWithCacheIfNeed(.userFeeling, keyword: keyword, cursor: cursor)
    }
    
    private func loadTagsWithCacheIfNeed(_ type: Tag.TagType,
                                         keyword: String,
                                         cursor: String?,
                                         cacheResult: Bool = false) -> Observable<SuggestTagResultCollection> {
        let needCache = cursor == nil
        let cache = needCache == false ? .empty()
            : self.local.fetchRecentSelectTags(type, query: keyword).catchAndReturn([])
            .map{ SuggestTagResultCollection(query: keyword, tags: $0, cursor: nil) }
        let remote = type == .userComments ? self.remote.requestLoadPlaceCommnetTags(keyword, cursor: cursor)
            : type == .userFeeling ? self.remote.requestLoadUserFeelingTags(keyword, cursor: cursor)
            : .empty()
        
        let updateCacheOrNot: (SuggestTagResultCollection) -> Void = { [weak self] collection in
            guard cacheResult, let self = self else { return }
            self.local.saveTags(collection.tags)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return cache.asObservable().concat(remote.do(onNext: updateCacheOrNot))
    }
}

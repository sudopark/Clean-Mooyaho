//
//  SuggestTagUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol SuggestTagUsecase { }


// MARK: - SuggestTagReqParams

public struct SuggestTagReqParams: SuggestReqParamType {
    
    public typealias Cursor = String
    
    public let query: String
    public let tagType: Tag.TagType
    public let cursor: String?
    public let onlyMine: Bool
    
    public init(query: String, tagType: Tag.TagType,
                cursor: String? = nil, onlyMine: Bool = false) {
        self.query = query
        self.tagType = tagType
        self.cursor = cursor
        self.onlyMine = onlyMine
    }
    
    public var isEmpty: Bool {
        return self.query.isEmpty
    }
    
    public func updateNextPageCursor(_ cursor: String) -> SuggestTagReqParams {
        return .init(query: self.query, tagType: self.tagType, cursor: cursor, onlyMine: self.onlyMine)
    }
}


// MARK: - SuggestTagResult collection as SuggestResultCollectionType

extension SuggestTagResultCollection: SuggestResultCollectionType {
    
    public typealias Cursor = String
    
    public var nextPageCursor: String? {
        return self.cursor
    }
    
    public func append(_ next: SuggestTagResultCollection) -> SuggestTagResultCollection {
        let nextPageCursor = next.tags.isEmpty ? nil : next.tags.last?.keyword
        let mergedTags = (self.tags + next.tags).removeDuplicated{ $0.keyword }
        return .init(query: self.query,
                     tags: mergedTags,
                     cursor: nextPageCursor)
    }
    
    public static func distinguisForSuggest(_ lhs: SuggestTagResultCollection,
                                            _ rhs: SuggestTagResultCollection) -> Bool {
        return lhs.tags.map{ $0.keyword } == rhs.tags.map{ $0.keyword }
    }
}


// MARK: - SuggestTagUsecaseImple

public final class SuggestTagUsecaseImple: SuggestTagUsecase {
    
    typealias ReqParams = SuggestTagReqParams
    typealias ResultCollection = SuggestTagResultCollection
    
    private let tagRepository: TagRespository
    private var internalSuggestUsecase: SuggestUsecase<SuggestTagReqParams, SuggestTagResultCollection>!
    
    public init(tagRepository: TagRespository) {
        self.tagRepository = tagRepository
        self.internalSuggestUsecase = .init { [weak self] params in
            return self?.suggest(params) ?? .empty()
        }
    }
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private func suggest(_ params: ReqParams) -> Observable<ResultCollection> {
        
        let asCollectoin: ([Tag]) -> ResultCollection = { tags in
            return .init(cached: tags)
        }
        
        switch params.tagType {
        case .userComments where params.query.isEmpty:
            return self.tagRepository.fetchRecentPlaceCommentTag()
                .catch{ _ in .empty() }
                .map(asCollectoin)
                .asObservable()
            
        case .userComments where params.query.isNotEmpty:
            return self.tagRepository
                .requestLoadPlaceCommnetTags(params.query, cursor: params.cursor)
                .catch{ _ in .empty() }
            
        case .userFeeling where params.query.isEmpty:
            return self.tagRepository.fetchRecentUserFeelingCommentTag(query: params.query)
                .catch{ _ in .empty() }
                .map(asCollectoin)
                .asObservable()
            
        case .userFeeling where params.query.isNotEmpty && params.onlyMine == true:
            return self.tagRepository.fetchRecentUserFeelingCommentTag(query: params.query)
                .catch{ _ in .empty() }
                .map(asCollectoin)
                .asObservable()
            
        case .userFeeling where params.query.isNotEmpty && params.onlyMine == false:
            return self.tagRepository
                    .requestLoadUserFeelingTags(params.query, cursor: params.cursor)
                    .catch{ _ in .empty() }
            
        default:
            return .empty()
            
        }
    }
}


// MARK: - SuggestTagUsecaseImple input

extension SuggestTagUsecaseImple {
    
    public func startSuggestPlaceCommentTag(_ query: String) {
        let params = ReqParams(query: query, tagType: .userComments)
        self.internalSuggestUsecase.startSuggest(params)
    }
    
    public func stratSuggestUserFeelingTag(_ query: String, onlyMine: Bool) {
        let params = ReqParams(query: query, tagType: .userFeeling, onlyMine: onlyMine)
        self.internalSuggestUsecase.startSuggest(params)
    }
    
    public func finishSuggest() {
        self.internalSuggestUsecase.stopSuggest()
    }
    
    public func loadMoreSuggest() {
        self.internalSuggestUsecase.suggestMore()
    }
}


// MARK: - SuggestTagUsecaseImple output

extension SuggestTagUsecaseImple {
    
    public var suggestTagResults: Observable<SuggestTagResultCollection?> {
        return self.internalSuggestUsecase.suggestResult
    }
}


private extension SuggestTagResultCollection {
    
    init(cached tags: [Tag]) {
        self.init(query: "", tags: tags, cursor: nil)
    }
}

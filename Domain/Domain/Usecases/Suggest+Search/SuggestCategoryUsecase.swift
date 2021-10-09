//
//  SuggestCategoryUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


// MARK: - SuggestCategoryUsecase

public protocol SuggestCategoryUsecase {
    
    func startSuggestCategories(query: String)
    
    func stopSuggest()
    
    func loadMore()
    
    var suggestedCategories: Observable<SuggestCategoryCollection?> { get }
    
    var isSuggesting: Observable<Bool> { get }
}


public struct SuggestCategoryReqParams: SuggestReqParamType {

    public typealias Cursor = String
    public let query: String?
    public var cursor: Cursor?
    
    public var isEmpty: Bool {
        return query?.isNotEmpty != true
    }
    
    public func updateNextPageCursor(_ cursor: String) -> SuggestCategoryReqParams {
        return self |> \.cursor .~ cursor
    }
}

extension SuggestCategoryCollection: SuggestResultCollectionType {
    
    public typealias Cursor = String
    
    public var nextPageCursor: String? {
        return self.cursor
    }
    
    public func append(_ next: SuggestCategoryCollection) -> SuggestCategoryCollection {
        return .init(query: self.query,
                     categories: self.categories + next.categories,
                     cursor: next.cursor)
    }
    
    public static func distinguisForSuggest(_ lhs: SuggestCategoryCollection,
                                            _ rhs: SuggestCategoryCollection) -> Bool {
        return lhs.query == rhs.query
            && lhs.categories.map{ $0.category} == rhs.categories.map { $0.category }
    }
}


// MARK: - SuggestCategoryUsecaseImple

public final class SuggestCategoryUsecaseImple: SuggestCategoryUsecase {
    
    typealias ReqParama = SuggestCategoryReqParams
    typealias ResultCollection = SuggestCategoryCollection

    private let repository: ItemCategoryRepository
    private var internalUsecase: SuggestUsecase<ReqParama, ResultCollection>!
    
    public init(repository: ItemCategoryRepository,
                throttleInterval: Int = 500) {
        self.repository = repository
        self.internalUsecase = .init(throttleInterval: throttleInterval) { [weak self] params in
            return self?.search(params).asObservable() ?? .empty()
        }
    }
    
    private func search(_ params: ReqParama) -> Maybe<ResultCollection> {
        guard let query = params.query, query.isNotEmpty else {
            return .just(.empty())
        }
        return self.repository.suggestItemCategory(name: query, cursor: params.cursor)
    }
}


extension SuggestCategoryUsecaseImple {
    
    public func startSuggestCategories(query: String) {
        let params = ReqParama(query: query, cursor: nil)
        self.internalUsecase.startSuggest(params)
    }
    
    public func stopSuggest() {
        self.internalUsecase.stopSuggest()
    }
    
    public func loadMore() {
        self.internalUsecase.suggestMore()
    }
}

extension SuggestCategoryUsecaseImple {
    
    public var suggestedCategories: Observable<SuggestCategoryCollection?> {
        return self.internalUsecase.suggestResult
    }
    
    public var isSuggesting: Observable<Bool> {
        return self.internalUsecase.isSuggesting
    }
}

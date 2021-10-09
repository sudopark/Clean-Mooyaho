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
    
    func startSuggestCategories(for memberID: String?, query: String)
    
    func stopSuggest()
    
    func loadMore()
    
    var suggestedCategories: Observable<SuggestCategoryCollection?> { get }
    
    var isSuggesting: Observable<Bool> { get }
}


public struct SuggestCategoryReqParams: SuggestReqParamType {

    public typealias Cursor = Int
    
    public let memberID: String?
    public let query: String?
    public var currentPage: Int?
    
    public var isEmpty: Bool {
        return query?.isNotEmpty != true
    }
    
    public func updateNextPageCursor(_ cursor: Int) -> SuggestCategoryReqParams {
        return self |> \.currentPage .~ cursor
    }
}

extension SuggestCategoryCollection: SuggestResultCollectionType {
    
    public typealias Cursor = Int
    
    public var nextPageCursor: Int? {
        guard let current = self.currentPage,
              self.isFinalPage == false else { return nil }
        
        return current + 1
    }
    
    public func append(_ next: SuggestCategoryCollection) -> SuggestCategoryCollection {
        return .init(query: self.query,
                     currentPage: next.currentPage,
                     categories: self.categories + next.categories,
                     isFinalPage: next.isFinalPage)
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
        return self.repository.suggestItemCategory(for: params.memberID, name: query)
            .catchAndReturn(.empty(query))
    }
}


extension SuggestCategoryUsecaseImple {
    
    public func startSuggestCategories(for memberID: String?, query: String) {
        let params = ReqParama(memberID: memberID, query: query, currentPage: nil)
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

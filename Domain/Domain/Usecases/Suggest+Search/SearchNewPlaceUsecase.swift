//
//  SearchNewPlaceUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - SearchNewPlaceUsecase

public protocol SearchNewPlaceUsecase {
    
    // input
    func startSearchPlace(for query: SuggestPlaceQuery, in location: UserLocation)
    func finishSearchPlace()
    func loadMorePlaceSearchResult()
    
    // output
    var newPlaceSearchResult: Observable<SearchingPlaceCollection?> { get }
}


// MARK: - SearchNewPlaceReqParams

public struct SearchNewPlaceReqParams: SuggestReqParamType {
    
    public let query: SuggestPlaceQuery
    public let location: UserLocation
    public let currentPage: Int?
    
    public init(query: SuggestPlaceQuery, location: UserLocation, currentPage: Int? = nil) {
        self.query = query
        self.location = location
        self.currentPage = currentPage
    }
    
    public typealias Cursor = Int
    public var isEmpty: Bool {
        guard case .empty = self.query else { return false }
        return true
    }
    
    public func updateNextPageCursor(_ cursor: Int) -> SearchNewPlaceReqParams {
        return .init(query: query, location: location, currentPage: cursor)
    }
}


// MARK: SearchingPlaceCollection for SuggestResultCollectionType

extension SearchingPlaceCollection: SuggestResultCollectionType {
    
    public typealias Cursor = Int
    
    public var nextPageCursor: Int? {
        guard let current = self.currentPage,
              self.isFinalPage == false else { return nil }
        
        return current + 1
    }
    
    
    public func append(_ next: SearchingPlaceCollection) -> SearchingPlaceCollection {
        return .init(query: self.query,
                     currentPage: next.currentPage,
                     places: self.places + next.places,
                     isFinalPage: next.isFinalPage)
    }
    
    public static func distinguisForSuggest(_ lhs: SearchingPlaceCollection,
                                            _ rhs: SearchingPlaceCollection) -> Bool {
        return lhs.query == rhs.query && lhs.places.map{ $0.uid } == rhs.places.map{ $0.uid }
    }
}


// MARK - SearchNewPlaceUsecaseImple

public final class SearchNewPlaceUsecaseImple: SearchNewPlaceUsecase {
    
    typealias ReqParama = SearchNewPlaceReqParams
    typealias ResultCollection = SearchingPlaceCollection
    
    private let repository: PlaceRepository
    private var internalSuggestUsecase: SuggestUsecase<ReqParama, ResultCollection>!
    
    public init(placeRepository: PlaceRepository) {
        self.repository = placeRepository
        self.internalSuggestUsecase = .init { [weak self] params in
            return self?.search(params).asObservable() ?? .empty()
        }
    }
    
    private func search(_ params: ReqParama) -> Maybe<ResultCollection> {
        guard params.query != .empty else { return .just(.empty("")) }
        let queryString = params.query.string
        return self.repository
            .requestSearchNewPlace(queryString, in: params.location, of: params.currentPage)
            .catch{ _ in .just(.empty(queryString)) }
    }
}


// MARK: - input

extension SearchNewPlaceUsecaseImple {
    
    public func startSearchPlace(for query: SuggestPlaceQuery, in location: UserLocation) {
        let params = ReqParama(query: query, location: location)
        self.internalSuggestUsecase.startSuggest(params)
    }
    
    public func finishSearchPlace() {
        self.internalSuggestUsecase.stopSuggest()
    }
    
    public func loadMorePlaceSearchResult() {
//        self.internalSuggestUsecase.suggestMore()
    }
}

// MARK: - output

extension SearchNewPlaceUsecaseImple {
    
    public var newPlaceSearchResult: Observable<SearchingPlaceCollection?> {
        return self.internalSuggestUsecase.suggestResult
    }
}

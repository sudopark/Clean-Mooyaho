//
//  SuggestPlaceUsecase.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


// MARK: SuggestPlaceUsecase

public protocol SuggestPlaceUsecase { }


// MARK: SuggestPlaceQuery requestParams

public enum SuggestPlaceQuery: Equatable {
    
    case empty
    case some(_ string: String)
    
    public var string: String {
        switch self {
        case .empty: return ""
        case let .some(string): return string
        }
    }
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty): return true
        case let (.some(left), .some(right)): return left == right
        default: return false
        }
    }
}

public struct PlaceSuggestReqParams: SuggestReqParamType {
    
    public let query: SuggestPlaceQuery
    public let location: UserLocation
    public let pageIndex: Int?
    
    public init(query: SuggestPlaceQuery, location: UserLocation, pageIndex: Int? = nil) {
        self.query = query
        self.location = location
        self.pageIndex = pageIndex
    }
    
    // conform SuggestReqParamType
    public typealias Cursor = Int
    public var isEmpty: Bool {
        guard case .empty = self.query else { return false }
        return true
    }
    
    public func appendNextPageCursor(_ cursor: Int) -> PlaceSuggestReqParams {
        return .init(query: self.query, location: self.location, pageIndex: cursor)
    }
}


// MARK: SuggestPlaceResult for SuggestResultCollectionType

extension SuggestPlaceResult: SuggestResultCollectionType {
    
    public typealias Cursor = Int
    
    public var nextPageCursor: Int? {
        guard let current = self.pageIndex else { return nil }
        return current + 1
    }
    
    public func append(_ next: SuggestPlaceResult) -> SuggestPlaceResult {
        return .init(query: self.query,
                     places: self.places + next.places,
                     pageIndex: next.pageIndex)
    }
    
    public static func distinguisForSuggest(_ lhs: SuggestPlaceResult, _ rhs: SuggestPlaceResult) -> Bool {
        return lhs.pageIndex == rhs.pageIndex
            && lhs.query == rhs.query
            && lhs.places.map{ $0.uid } == rhs.places.map{ $0.uid }
    }
}


public final class SuggestPlaceUsecaseImple {

    private let placeRepository: PlaceRepository
    private var internalSuggestUsecase: SuggestUsecase<PlaceSuggestReqParams, SuggestPlaceResult>!
    
    public init(placeRepository: PlaceRepository) {
        self.placeRepository = placeRepository
        self.internalSuggestUsecase = .init { [weak self] params in
            return self?.suggestByQuery(params) ?? .empty()
        }
    }

    private let disposeBag: DisposeBag = DisposeBag()
    private let cachedDefaultSuggestRelay = BehaviorRelay<SuggestPlaceResult?>(value: nil)
}


// MARK: - input

extension SuggestPlaceUsecaseImple {
    
    public func startSuggestPlace(for query: SuggestPlaceQuery, in location: UserLocation) {
        let params = PlaceSuggestReqParams(query: query, location: location)
        self.internalSuggestUsecase.startSuggest(params)
    }
    
    public func finishPlaceSuggesting() {
        self.internalSuggestUsecase.stopSuggest()
    }
    
    public func loadMoreSuggestPages() {
        self.internalSuggestUsecase.suggestMore()
    }
}


// MARK: - output

extension SuggestPlaceUsecaseImple {
    
    private var isSuggesting: Observable<Bool> {
        return self.internalSuggestUsecase.isSuggesting
    }
    
    public var placeSuggestResult: Observable<SuggestPlaceResult?> {
        return self.internalSuggestUsecase.suggestResult
    }
}


extension SuggestPlaceUsecaseImple {
    
    private func suggestByQuery(_ params: PlaceSuggestReqParams) -> Maybe<SuggestPlaceResult> {
        switch params.query {
        case .empty:
            return self.loadDefaultSuggest(params.location)
            
        case let .some(text):
            return self.placeRepository.requestSuggestPlace(text, in: params.location, page: params.pageIndex)
        }
    }
    
    private func loadDefaultSuggest(_ location: UserLocation) -> Maybe<SuggestPlaceResult> {
        if let cachedValue = self.cachedDefaultSuggestRelay.value {
            return .just(cachedValue)
        }
        let updateCache: (SuggestPlaceResult) -> Void = { [weak self] result in
            self?.cachedDefaultSuggestRelay.accept(result)
        }
        return self.placeRepository.reqeustLoadDefaultPlaceSuggest(in: location)
            .do(onNext: updateCache)
    }
}

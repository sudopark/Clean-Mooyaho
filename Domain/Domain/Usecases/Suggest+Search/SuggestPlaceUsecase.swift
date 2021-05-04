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


public enum Query: Equatable {
    
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

public protocol SuggestPlaceUsecase { }


public final class SuggestPlaceUsecaseImple {
    
    struct PlaceSuggestReqParams {
        let query: Query
        let location: UserLocation
        let pageIndex: Int?
        
        init(query: Query, location: UserLocation, pageIndex: Int? = nil) {
            self.query = query
            self.location = location
            self.pageIndex = pageIndex
        }
    }
    
    private let placeRepository: PlaceRepository
    public init(placeRepository: PlaceRepository) {
        self.placeRepository = placeRepository
        self.internalBinding()
    }
    
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let suggestPlaceReqParamsRelay = BehaviorRelay<PlaceSuggestReqParams?>(value: nil)
    private let suggestPlaceResultRelay = BehaviorRelay<SuggestPlaceResult?>(value: nil)
    private let cachedDefaultSuggestRelay = BehaviorRelay<SuggestPlaceResult?>(value: nil)
}


// MARK: - input

extension SuggestPlaceUsecaseImple {
    
    
    public func startSuggestPlace(for query: Query, in location: UserLocation) {
        let params = PlaceSuggestReqParams(query: query, location: location)
        self.suggestPlaceReqParamsRelay.accept(params)
    }
    
    public func finishPlaceSuggesting() {
        self.suggestPlaceReqParamsRelay.accept(nil)
        self.suggestPlaceResultRelay.accept(nil)
    }
    
    public func suggestMore() {
        guard let params = self.suggestPlaceReqParamsRelay.value,
              params.query != .empty,
              let result = self.suggestPlaceResultRelay.value,
              let currentPageIndex = result.pageIndex else { return }
        
        let nextPageIndex = currentPageIndex + 1
        let newParams = PlaceSuggestReqParams(query: params.query, location: params.location, pageIndex: nextPageIndex)
        self.suggestPlaceReqParamsRelay.accept(newParams)
    }
}


// MARK: - output

extension SuggestPlaceUsecaseImple {
    
    private var isSuggesting: Observable<Bool> {
        return self.suggestPlaceReqParamsRelay
            .map{ $0 != nil }
    }
    
    public var placeSuggestResult: Observable<SuggestPlaceResult?> {
        
        typealias Result = SuggestPlaceResult
        
        let accumulateOrFinishingPaging: (Result?, Result?) -> Result? = { accumulated, newResult in
            switch (accumulated, newResult) {
            case (.none, .none), (_, .none): return nil
            case let (.none, .some(new)): return new
            case let (.some(previous), .some(next)):
                return previous.query != next.query ? next : previous.appended(next)
            }
        }
        
        return self.suggestPlaceResultRelay
            .scan(nil, accumulator: accumulateOrFinishingPaging)
            .distinctUntilChanged(Result.quickCompare)
    }
}


extension SuggestPlaceUsecaseImple {
    
    private func loadDefaultSuggest(_ location: UserLocation) -> Observable<SuggestPlaceResult> {
        if let cachedValue = self.cachedDefaultSuggestRelay.value {
            return .just(cachedValue)
        }
        let updateCache: (SuggestPlaceResult) -> Void = { [weak self] result in
            self?.cachedDefaultSuggestRelay.accept(result)
        }
        return self.placeRepository.reqeustLoadDefaultPlaceSuggest(in: location)
            .do(onNext: updateCache)
            .catch{ _ in .empty() }
            .asObservable()
    }
    
    private func suggestPlace(_ params: PlaceSuggestReqParams) -> Observable<SuggestPlaceResult> {
        return self.placeRepository
            .requestSuggestPlace(params.query.string, in: params.location, page: params.pageIndex)
            .catch{ _ in .empty() }
            .asObservable()
    }
    
    private func internalBinding() {
        
        let suggestOrShowDefault: (PlaceSuggestReqParams) -> Observable<SuggestPlaceResult?>
        suggestOrShowDefault = { [weak self] params in
            guard let self = self else { return .empty() }
            let result = params.query == .empty
                ? self.loadDefaultSuggest(params.location)
                : self.suggestPlace(params)
            return result.asOptional()
        }
        
        self.suggestPlaceReqParamsRelay
            .compactMap{ $0 }
            .flatMapLatest(suggestOrShowDefault)
            .subscribe(onNext: { [weak self] result in
                self?.suggestPlaceResultRelay.accept(result)
            })
            .disposed(by: self.disposeBag)
    }
}

private extension SuggestPlaceResult {
    
    static func quickCompare(_ lhs: Self?, _ rhs: Self?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): return true
        case let (.some(left), .some(right)): return left.isEqual(with: right)
        default: return false
        }
    }
    
    func isEqual(with other: Self) -> Bool {
        return self.pageIndex == other.pageIndex
            && self.query == other.query
            && self.places.map{ $0.uid } == other.places.map{ $0.uid }
    }
    
    func appended(_ next: Self) -> Self {
        return .init(query: self.query,
                     places: self.places + next.places,
                     pageIndex: next.pageIndex)
    }
}

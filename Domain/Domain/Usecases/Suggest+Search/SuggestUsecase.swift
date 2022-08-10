//
//  SuggestUsecase.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


// MARK: - suggest request parms and result type

public protocol SuggestReqParamType: Sendable {
    
    associatedtype Cursor: Equatable
    
    var isEmpty: Bool { get }
    
    func updateNextPageCursor(_ cursor: Cursor) -> Self
}

public protocol SuggestResultCollectionType: Sendable {
    
    associatedtype Cursor: Equatable
    
    var query: String { get }

    var nextPageCursor: Cursor? { get }

    func append(_ next: Self) -> Self
    
    static func distinguisForSuggest(_ lhs: Self, _ rhs: Self) -> Bool
}


// MARK: - generic suggest usecase

open class SuggestUsecase<ReqType: SuggestReqParamType, ResultType: SuggestResultCollectionType>
    where ReqType.Cursor == ResultType.Cursor  {
    
    public typealias API = (ReqType) -> Observable<ResultType>
    private let api: API
    
    public let throttleInterval: Int
    
    public init(throttleInterval: Int, api: @escaping API) {
        self.throttleInterval = throttleInterval
        self.api = api
        self.internalBinding()
    }
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let requestParamsRelay = BehaviorRelay<ReqType?>(value: nil)
    private let resultRelay = BehaviorRelay<ResultType?>(value: nil)
}

// MARK: - suggest usecase input

extension SuggestUsecase {
    
    public func startSuggest(_ parameter: ReqType) {
        self.requestParamsRelay.accept(parameter)
    }
    
    public func stopSuggest() {
        self.requestParamsRelay.accept(nil)
        self.resultRelay.accept(nil)
    }
    
    public func suggestMore() {
        guard let params = self.requestParamsRelay.value,
              params.isEmpty == false,
              let result = self.resultRelay.value,
              let nextCursor = result.nextPageCursor else { return }
        let newParams = params.updateNextPageCursor(nextCursor)
        self.requestParamsRelay.accept(newParams)
    }
}


// MARK: - suggest usecase output

extension SuggestUsecase {
    
    public var isSuggesting: Observable<Bool> {
        return self.requestParamsRelay
            .map{ $0 != nil }
    }
    
    public var suggestResult: Observable<ResultType?> {
        
        let accumulateOrFinishingPaging: (ResultType?, ResultType?) -> ResultType? = { accumulated, newResult in
            switch (accumulated, newResult) {
            case (.none, .none), (_, .none): return nil
            case let (.none, .some(new)): return new
            case let (.some(previous), .some(next)):
                guard previous.query == next.query,
                      ResultType.distinguisForSuggest(previous, next) == false else {
                    return newResult
                }
                return previous.append(next)
            }
        }
        
        let removeDuplicatedResult: (ResultType?, ResultType?) -> Bool = { previous, next in
            switch (previous, next) {
            case (.none, .none): return true
            case let (.some(old), .some(new)): return ResultType.distinguisForSuggest(old, new)
            default: return false
            }
        }
        
        return self.resultRelay
            .scan(nil, accumulator: accumulateOrFinishingPaging)
            .distinctUntilChanged(removeDuplicatedResult)
    }
}


// MARK: - internal binding

extension SuggestUsecase {
    
    private func internalBinding() {
        
        let requestSuggesting: (ReqType) -> Observable<ResultType> = { [weak self] params in
            guard let self = self else { return .empty() }
            return self.api(params).catch{ _ in .empty() }.asObservable()
        }
        
        let updateResult: (ResultType) -> Void = { [weak self] result in
            self?.resultRelay.accept(result)
        }
        
        self.requestParamsRelay
            .compactMap{ $0 }
            .throttle(.milliseconds(self.throttleInterval), scheduler: MainScheduler.instance)
            .flatMapLatest(requestSuggesting)
            .subscribe(onNext: updateResult)
            .disposed(by: self.disposeBag)
    }
}

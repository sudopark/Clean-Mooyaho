//
//  PagingUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/12/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics


// MARK: - PagingLoadParameter

public protocol PagingLoadParameter {
    
    associatedtype Cursor
    
    var isFirst: Bool { get }
}


// MARK: - PagingLoadResult

public protocol PagingLoadResult {
    
    associatedtype Parameter: PagingLoadParameter
    
    var isFirst: Bool { get }
    var isAllLoaded: Bool { get }
    
    func append(next: Self) -> Self
    
    func nextParameter(from previous: Parameter) -> Parameter?
    
    static func distinguish(_ old: Self, _ next: Self) -> Bool
}


// MARK: - PagingUsecase

public protocol PagingUsecase {
    
    associatedtype Item: PagingLoadResult

    func load(_ parameter: Item.Parameter)
    func loadMore()
    
    var result: Observable<Item?> { get }
    var isLoading: Observable<Bool> { get }
}


// MARK: - PagingUsecaseImple

public final class PagingUsecaseImple<LoadResult: PagingLoadResult>: PagingUsecase {
    
    public typealias API = (LoadResult.Parameter) -> Maybe<LoadResult>
    private let api: API
    
    public init(api: @escaping API) {
        
        self.api = api
        self.internalBinding()
    }
    
    private let disposeBag = DisposeBag()
    private let requestParamsRelay = BehaviorRelay<LoadResult.Parameter?>(value: nil)
    private let resultRelay = BehaviorRelay<LoadResult?>(value: nil)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    private func internalBinding() {
        
        let updateIsLoading: (LoadResult.Parameter) -> Void = { [weak self] _ in
            self?.isLoadingRelay.accept(true)
        }
        
        let requestLoad: (LoadResult.Parameter) -> Maybe<LoadResult> = { [weak self] parameter in
            guard let self = self else { return .empty() }
            return self.api(parameter).catch { _ in .empty() }
        }
        
        let handleLoadResult: (Event<LoadResult>) -> Void = { [weak self] event in
            self?.isLoadingRelay.accept(false)
            guard case let .next(result) = event else { return }
            self?.resultRelay.accept(result)
        }
        
        self.requestParamsRelay
            .compactMap { $0 }
            .do(onNext: updateIsLoading)
            .flatMapLatest(requestLoad)
            .subscribe(handleLoadResult)
            .disposed(by: self.disposeBag)
    }
}


extension PagingUsecaseImple {
    
    public func load(_ parameter: LoadResult.Parameter) {
        self.requestParamsRelay.accept(parameter)
    }
    
    public func loadMore() {
        
        guard let previousParameter = self.requestParamsRelay.value,
              let result = self.resultRelay.value,
              result.isAllLoaded == false,
              let nextParams = result.nextParameter(from: previousParameter)
        else {
            return
        }
        self.requestParamsRelay.accept(nextParams)
    }
}


extension PagingUsecaseImple {
    
    public var result: Observable<LoadResult?> {
        
        let accumulateOrReset: (LoadResult?, LoadResult?) -> LoadResult? = { acculated, newResult in
            switch (acculated, newResult) {
            case (_, .none): return nil
            case let (.none, .some(new)): return new
            case let (.some, .some(new)) where new.isFirst: return new
            case let (.some(prev), .some(new)): return prev.append(next: new)
            }
        }
        
        let removeDuplicated: (LoadResult?, LoadResult?) -> Bool = { previous, next in
            switch (previous, next) {
            case (.none, .none): return true
            case let (.some(prev), .some(new)): return LoadResult.distinguish(prev, new)
            default: return false
            }
        }
        
        return self.resultRelay
            .scan(nil, accumulator: accumulateOrReset)
            .distinctUntilChanged(removeDuplicated)
    }
    
    public var isLoading: Observable<Bool> {
        return self.isLoadingRelay
            .distinctUntilChanged()
        
    }
}

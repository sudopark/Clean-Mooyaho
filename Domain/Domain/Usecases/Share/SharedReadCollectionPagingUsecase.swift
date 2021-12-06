//
//  SharedReadCollectionPagingUsecase.swift
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


// MARK: - SharedCollectionPagingParameter

public struct SharedCollectionPagingParameter: PagingLoadParameter {
    
    public typealias Cursor = [String]
    
    let collectionIDs: [String]
    public let isFirst: Bool
    
    public init(collectionIDs: [String] = [], isFirst: Bool = false) {
        self.collectionIDs = collectionIDs
        self.isFirst = isFirst
    }
    
    
    static var initial: Self {
        return .init(isFirst: true)
    }
}


// MARK: - SharedCollectionPagingResult

public struct SharedCollectionPagingResult: PagingLoadResult {
    
    public typealias Parameter = SharedCollectionPagingParameter
    
    let collections: [SharedReadCollection]
    public let isFirst: Bool
    public let isAllLoaded: Bool
    
    private let restCollectionIDs: [String]
    
    init(collections: [SharedReadCollection],
         restIDs: [String],
         isFirst: Bool,
         isAllLoaded: Bool) {
        
        self.collections = collections
        self.restCollectionIDs = restIDs
        self.isFirst = isFirst
        self.isAllLoaded = isAllLoaded
    }
    
    static var last: Self {
        return .init(collections: [], restIDs: [], isFirst: false, isAllLoaded: true)
    }
    
    public func nextParameter(from previous: SharedCollectionPagingParameter) -> SharedCollectionPagingParameter? {
        return SharedCollectionPagingParameter(collectionIDs: self.restCollectionIDs)
    }
    
    public func append(next: SharedCollectionPagingResult) -> SharedCollectionPagingResult {
        return SharedCollectionPagingResult(
            collections: self.collections + next.collections,
            restIDs: next.restCollectionIDs,
            isFirst: next.isFirst,
            isAllLoaded: next.collections.isEmpty
        )
    }
    
    public static func distinguish(_ old: SharedCollectionPagingResult,
                                   _ next: SharedCollectionPagingResult) -> Bool {
        return old.collections.map { $0.uid } == next.collections.map { $0.uid }
    }
}


// MARK: - SharedReadCollectionPagingUsecase

public protocol SharedReadCollectionPagingUsecase {
    
    func reloadSharedCollections()
    func loadMoreSharedCollections()
    
    var collections: Observable<[SharedReadCollection]> { get }
    var isRefreshing: Observable<Bool> { get }
    var isLoadingMore: Observable<Bool> { get }
}


// MARK: - SharedReadCollectionPagingUsecaseImple

public final class SharedReadCollectionPagingUsecaseImple: SharedReadCollectionPagingUsecase {
    
    private let repository: ShareItemRepository
    private let sharedDataStoreService: SharedDataStoreService
    private var internalUsecase: PagingUsecaseImple<SharedCollectionPagingResult>!
    
    public init(repository: ShareItemRepository,
                sharedDataStoreService: SharedDataStoreService) {
        self.repository = repository
        self.sharedDataStoreService = sharedDataStoreService
        
        self.internalUsecase = .init { [weak self] params in
            guard let self = self else { return .empty() }
            return self.loadCollection(params)
        }
    }
    
    private let disposeBag = DisposeBag()
    private let isRefreshingRelay = BehaviorRelay<Bool>(value: false)
    
    private func loadCollection(_ parameter: SharedCollectionPagingParameter) -> Maybe<SharedCollectionPagingResult> {
        
        guard parameter.collectionIDs.isNotEmpty else { return .just(.last) }
        
        let prefixedIDs = parameter.collectionIDs.prefix(10) |> Array.init
        let restIDs = parameter.collectionIDs.dropFirst(prefixedIDs.count) |> Array.init
        
        let loadCollection = self.repository.requestLoadSharedCollections(by: prefixedIDs)
        let asLoadResult: ([SharedReadCollection]) -> SharedCollectionPagingResult = { collections in
            return .init(collections: collections, restIDs: restIDs,
                         isFirst: parameter.isFirst, isAllLoaded: collections.isEmpty)
        }
        return loadCollection
            .ignoreError()
            .map(asLoadResult)
    }
}


extension SharedReadCollectionPagingUsecaseImple {
    
    public func reloadSharedCollections() {
        
        guard self.isRefreshingRelay.value == false else { return }
        
        let loadTotalCollectionIDs = self.repository.requestLoadAllSharedCollectionIDs()
        let asLoadParameter: ([String]) -> SharedCollectionPagingParameter = { collectionIDs in
            return .init(collectionIDs: collectionIDs, isFirst: true)
        }
        let handleError: (Error) -> Void = { [weak self] _ in
            self?.isRefreshingRelay.accept(false)
        }
        let startLoad: (SharedCollectionPagingParameter) -> Void = { [weak self] params in
            self?.isRefreshingRelay.accept(false)
            self?.internalUsecase.load(params)
        }
        
        self.isRefreshingRelay.accept(true)
        
        loadTotalCollectionIDs
            .map(asLoadParameter)
            .subscribe(onSuccess: startLoad, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func loadMoreSharedCollections() {
        
        guard self.isRefreshingRelay.value == false else { return }
        self.internalUsecase.loadMore()
    }
}

extension SharedReadCollectionPagingUsecaseImple {
    
    public var collections: Observable<[SharedReadCollection]> {
        return self.internalUsecase.result
            .map { $0?.collections ?? [] }
    }
    
    public var isRefreshing: Observable<Bool> {
        return self.isRefreshingRelay
            .distinctUntilChanged()
    }
    
    public var isLoadingMore: Observable<Bool> {
        return self.internalUsecase
            .isLoading
    }
}

//
//  FavoriteItemsPagingUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/30.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics


// MARK: - FavoriteItemsPagingUsecase

public protocol FavoriteItemsPagingUsecase: Sendable {
    
    func reloadFavoriteItems()
    
    func loadMoreItems()
    
    var items: Observable<[ReadItem]> { get }
    var isRefreshing: Observable<Bool> { get }
}


// MARK: - FavoriteItemsPagingParameter

public struct FavoriteItemsPagingParameter: SuggestReqParamType {
    
    public typealias Cursor = [String]
    
    let fakeQuery: String
    var restTotalItemIDs: [String]
    let chunkSize: Int
    
    public init(totalItemIDs: [String], chunkSize: Int = 10) {
        self.fakeQuery = UUID().uuidString
        self.restTotalItemIDs = totalItemIDs
        self.chunkSize = chunkSize
    }
    
    public var isEmpty: Bool {
        return self.restTotalItemIDs.isEmpty
    }
    
    public func updateNextPageCursor(_ cursor: [String]) -> FavoriteItemsPagingParameter {
        return self |> \.restTotalItemIDs .~ cursor
    }
}


// MARK: - FavoriteItemsResultCollection

public struct FavoriteItemsResultCollection: SuggestResultCollectionType {
    
    public typealias Cursor = [String]
    
    public let query: String
    
    private let chunkSize: Int
    public var nextPageCursor: [String]?
    public var items: [ReadItem] = []
    
    public init(query: String, ids: [String]?, size: Int = 10) {
        self.query = query
        self.chunkSize = size
        self.nextPageCursor = ids
    }
    
    public func append(_ next: FavoriteItemsResultCollection) -> FavoriteItemsResultCollection {
        return .init(query: next.query, ids: next.nextPageCursor, size: self.chunkSize)
            |> \.items .~ (self.items + next.items)
    }
    
    public static func distinguisForSuggest(_ lhs: FavoriteItemsResultCollection,
                                            _ rhs: FavoriteItemsResultCollection) -> Bool {
        let idsLhs = lhs.items.map { $0.uid }
        let idsRhs = rhs.items.map { $0.uid }
        return idsLhs == idsRhs
    }
}


public final class FavoriteItemsPagingUsecaseImple: FavoriteItemsPagingUsecase, @unchecked Sendable {
    
    private let favoriteItemsUsecase: FavoriteReadItemUsecas
    private let readItemLoadUsecase: ReadItemLoadUsecase
    private var internalPagingUsecase: SuggestUsecase<FavoriteItemsPagingParameter, FavoriteItemsResultCollection>!
    
    public init(favoriteItemsUsecase: FavoriteReadItemUsecas,
                itemsLoadUsecase: ReadItemLoadUsecase,
                throttleInterval: TimeInterval = 0.5) {
        self.favoriteItemsUsecase = favoriteItemsUsecase
        self.readItemLoadUsecase = itemsLoadUsecase
        
        let interval = Int(throttleInterval * 1000)
        self.internalPagingUsecase = .init(throttleInterval: interval) { [weak self] params in
            guard let self = self else { return .empty() }
            return self.loadFavoriteItems(params).asObservable()
        }
    }
    
    private let disposeBag = DisposeBag()
    private let isPrepareReloading = BehaviorRelay<Bool>(value: false)
    
    private func loadFavoriteItems(_ params: FavoriteItemsPagingParameter) -> Maybe<FavoriteItemsResultCollection> {
        guard params.isEmpty == false else { return .empty() }
        
        let size = params.chunkSize
        let prefixedIDs = params.restTotalItemIDs.prefix(size) |> Array.init
        
        let asResultCollection: ([ReadItem]) -> FavoriteItemsResultCollection = { items in
            let restIDs = params.restTotalItemIDs.dropFirst(prefixedIDs.count) |> Array.init
            return .init(query: params.fakeQuery, ids: restIDs, size: size)
                |> \.items .~ items
        }
        return self.readItemLoadUsecase.loadReadItems(for: prefixedIDs)
            .ignoreError()
            .map(asResultCollection)
    }
}


extension FavoriteItemsPagingUsecaseImple {
    
    public func reloadFavoriteItems() {
        guard self.isPrepareReloading.value == false else { return }
        
        let chunkSize = 10
        let reloadFavoriteIDs = self.favoriteItemsUsecase.refreshFavoriteIDs()
            .takeLast(1)
            .catch { [weak self] _ in
                self?.isPrepareReloading.accept(false)
                return .empty()
            }
        let reverseOrder: ([String]) -> [String] = { $0.reversed() }
        let asPagingParameter: ([String]) -> FavoriteItemsPagingParameter = { totalIDs in
            return .init(totalItemIDs: totalIDs, chunkSize: chunkSize)
        }
        let thenStartLoadItems: (FavoriteItemsPagingParameter) -> Void = { [weak self] params in
            guard let self = self else { return }
            self.isPrepareReloading.accept(false)
            self.internalPagingUsecase.startSuggest(params)
        }
        
        self.isPrepareReloading.accept(true)
        reloadFavoriteIDs
            .map(reverseOrder)
            .map(asPagingParameter)
            .subscribe(onNext: thenStartLoadItems)
            .disposed(by: self.disposeBag)
    }
    
    public func loadMoreItems() {
        self.internalPagingUsecase.suggestMore()
    }
}


extension FavoriteItemsPagingUsecaseImple {
    
    public var items: Observable<[ReadItem]> {
        return self.internalPagingUsecase.suggestResult
            .map { $0?.items ?? [] }
    }
    
    public var isRefreshing: Observable<Bool> {
        return self.isPrepareReloading
            .distinctUntilChanged()
    }
}

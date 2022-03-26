//
//  StubFavoritePagingUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/12/01.
//

import Foundation

import RxSwift
import RxRelay

import Domain


open class StubFavoritePagingUsecase: FavoriteItemsPagingUsecase {
    
    private let fakeItems = BehaviorRelay<[ReadItem]?>(value: nil)
    private let fakeIsRefreshing = BehaviorRelay<Bool>(value: false)
    
    public init() {}
    
    public var totalItems: [ReadItem] = [] {
        didSet {
            self.itemsBuffer = totalItems
        }
    }
    
    private var itemsBuffer: [ReadItem] = []
    public var pageSize = 10
    
    public func reloadFavoriteItems() {
        self.itemsBuffer = self.totalItems
        let first = self.itemsBuffer.safeEnqueue(self.pageSize)
        self.fakeItems.accept(first)
    }
    
    public func loadMoreItems() {
        let next = self.itemsBuffer.safeEnqueue(self.pageSize)
        guard next.isNotEmpty else { return }
        let newValue = (self.fakeItems.value ?? []) + next
        self.fakeItems.accept(newValue)
    }
    
    
    public var items: Observable<[ReadItem]> {
        return self.fakeItems.compactMap { $0 }
    }
    
    public var isRefreshing: Observable<Bool> {
        return self.fakeIsRefreshing
            .distinctUntilChanged()
    }
}


private extension Array where Element == ReadItem {
    
    mutating func safeEnqueue(_ size: Int) -> Array {
        let sender = Array(self.prefix(size))
        self = Array(self.dropFirst(sender.count))
        return sender
    }
}

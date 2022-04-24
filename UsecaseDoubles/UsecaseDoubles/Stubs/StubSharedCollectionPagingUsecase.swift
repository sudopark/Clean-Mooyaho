//
//  StubSharedCollectionPagingUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/12/08.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain


public final class StubSharedCollectionPagingUsecase: SharedReadCollectionPagingUsecase {
    
    public init() {}
    
    public var loadedCollectionLists: [[SharedReadCollection]] = []
    
    public func reloadSharedCollections() {
        self.updateFakeSubjectIfNeed()
    }
    
    public func loadMoreSharedCollections() {
        self.updateFakeSubjectIfNeed(append: true)
    }
    
    private func updateFakeSubjectIfNeed(append: Bool = false) {
        guard self.loadedCollectionLists.isNotEmpty else { return }
        let first = self.loadedCollectionLists.removeFirst()
        if append {
            let new = (self.fakeCollections.value ?? []) + first
            self.fakeCollections.accept(new)
        } else {
            self.fakeCollections.accept(first)
        }
    }
    
    private let fakeCollections = BehaviorRelay<[SharedReadCollection]?>(value: nil)
    public var collections: Observable<[SharedReadCollection]> {
        return self.fakeCollections.compactMap { $0 }
    }
    
    public var isRefreshing: Observable<Bool> {
        return .empty()
    }
    
    public var isLoadingMore: Observable<Bool> {
        return .empty()
    }
}

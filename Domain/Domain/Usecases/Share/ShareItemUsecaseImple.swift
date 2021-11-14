//
//  ShareItemUsecaseImple.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


public final class ShareItemUsecaseImple: ShareReadCollectionUsecase, SharedReadCollectionLoadUsecase, SharedReadCollectionHandleUsecase {
    
    private let shareRepository: ShareItemRepository
    private let authInfoProvider: AuthInfoProvider
    private let sharedDataService: SharedDataStoreService
    
    public init(shareRepository: ShareItemRepository,
                authInfoProvider: AuthInfoProvider,
                sharedDataService: SharedDataStoreService) {
        self.shareRepository = shareRepository
        self.authInfoProvider = authInfoProvider
        self.sharedDataService = sharedDataService
    }
    
    private let disposeBag = DisposeBag()
}


// MARK: - share

extension ShareItemUsecaseImple {
    
    public func shareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection> {
        
        return self.shareRepository.requestShareCollection(collection)
    }
    
    public func stopShare(collection collecionID: String) -> Maybe<Void> {
        
        return self.shareRepository.requestStopShare(readCollection: collecionID)
    }
}


// MARK: - load

extension ShareItemUsecaseImple {
    
    public func refreshLatestSharedReadCollection() {
        
        let refreshStora: ([SharedReadCollection]) -> Void = { [weak self] collections in
            let datKey = SharedDataKeys.latestSharedCollections.rawValue
            self?.sharedDataService
                .update([SharedReadCollection].self, key: datKey) { _ in collections }
        }
        
        self.shareRepository.requestLoadLatestsSharedCollections()
            .subscribe(onNext: refreshStora)
            .disposed(by: self.disposeBag)
    }
    
    public var lastestSharedReadCollections: Observable<[SharedReadCollection]> {
        let datKey = SharedDataKeys.latestSharedCollections.rawValue
        return self.sharedDataService
            .observeWithCache([SharedReadCollection].self, key: datKey)
            .map { $0 ?? [] }
    }
}


// MARK: - handle

extension ShareItemUsecaseImple {
    
    
    public func loadSharedCollection(by sharedURL: String) -> Maybe<ShareReadCollectionUsecase> {
        return .empty()
    }
}

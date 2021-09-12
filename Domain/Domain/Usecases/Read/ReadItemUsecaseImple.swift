//
//  ReadItemUsecaseImple.swift
//  Domain
//
//  Created by sudo.park on 2021/09/12.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public final class ReadItemUsecaseImple {
    
    private let readItemRepository: ReadItemRepository
    private let authInfoProvider: AuthInfoProvider
    
    public init(readItemRepository: ReadItemRepository,
                authInfoProvider: AuthInfoProvider) {
        self.readItemRepository = readItemRepository
        self.authInfoProvider = authInfoProvider
    }
}


extension ReadItemUsecaseImple: ReadItemLoadUsecase {
    
    public func loadMyItems() -> Observable<[ReadItem]> {
        let memberID = self.authInfoProvider.signedInMemberID()
        return self.readItemRepository.requestLoadMyItems(for: memberID)
    }
    
    public func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        let memberID = self.authInfoProvider.signedInMemberID()
        return self.readItemRepository
            .requestLoadCollectionItems(for: memberID, collectionID: collectionID)
    }
}


extension ReadItemUsecaseImple: ReadItemUpdateUsecase {
    
    public func makeCollection(_ collection: ReadCollection, at parentID: String?) -> Maybe<Void> {
        return .empty()
    }
    
    public func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        return .empty()
    }
    
    public func saveLink(_ link: String, at collectionID: String?) -> Maybe<Void> {
        return .empty()
    }
    
    public func saveLink(_ link: ReadLink, at collectionID: String?) -> Maybe<Void> {
        return .empty()
    }
}

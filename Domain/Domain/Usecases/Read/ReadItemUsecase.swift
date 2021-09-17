//
//  ReadItemUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/12.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


// MARK: - ReadItemUsecase

public protocol ReadItemUsecase: ReadItemLoadUsecase, ReadItemUpdateUsecase { }


// MARK: - ReadItemUsecaseImple

public final class ReadItemUsecaseImple: ReadItemUsecase {
    
    private var readItemRepository: ReadItemRepository
    private let authInfoProvider: AuthInfoProvider
    
    public init(readItemRepository: ReadItemRepository,
                authInfoProvider: AuthInfoProvider) {
        self.readItemRepository = readItemRepository
        self.authInfoProvider = authInfoProvider
    }
}


extension ReadItemUsecaseImple {
    
    public func loadMyItems() -> Observable<[ReadItem]> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.readItemRepository.fetchMyItems().asObservable()
        }
        return self.readItemRepository.requestLoadMyItems(for: memberID)
    }
    
    public func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        guard self.authInfoProvider.isSignedIn() else {
            return self.readItemRepository
                .fetchCollectionItems(collectionID: collectionID).asObservable()
        }
        return self.readItemRepository.requestLoadCollectionItems(collectionID: collectionID)
    }
}


extension ReadItemUsecaseImple {
    
    public func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        guard self.authInfoProvider.isSignedIn() else {
            return self.readItemRepository.updateCollection(newCollection)
        }
        return self.readItemRepository.requestUpdateCollection(newCollection)
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        guard self.authInfoProvider.isSignedIn() else {
            return self.readItemRepository.updateLink(link)
        }
        return self.readItemRepository.requestUpdateLink(link)
    }
}

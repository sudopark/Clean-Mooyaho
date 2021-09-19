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

public protocol ReadItemUsecase: ReadItemLoadUsecase, ReadItemUpdateUsecase, ReadItemOptionsUsecase { }


// MARK: - ReadItemUsecaseImple

public final class ReadItemUsecaseImple: ReadItemUsecase {
    
    private let itemsRespoitory: ReadItemRepository
    private let optionsRespository: ReadItemOptionsRepository
    private let authInfoProvider: AuthInfoProvider
    
    public init(itemsRespoitory: ReadItemRepository,
                optionsRespository: ReadItemOptionsRepository,
                authInfoProvider: AuthInfoProvider) {
        self.itemsRespoitory = itemsRespoitory
        self.optionsRespository = optionsRespository
        self.authInfoProvider = authInfoProvider
    }
}


extension ReadItemUsecaseImple {
    
    public func loadMyItems() -> Observable<[ReadItem]> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.itemsRespoitory.fetchMyItems().asObservable()
        }
        return self.itemsRespoitory.requestLoadMyItems(for: memberID)
    }
    
    public func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]> {
        guard self.authInfoProvider.isSignedIn() else {
            return self.itemsRespoitory
                .fetchCollectionItems(collectionID: collectionID).asObservable()
        }
        return self.itemsRespoitory.requestLoadCollectionItems(collectionID: collectionID)
    }
}


extension ReadItemUsecaseImple {
    
    public func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.itemsRespoitory.updateCollection(newCollection)
        }
        let newCollection = newCollection |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateCollection(newCollection)
    }
    
    public func updateLink(_ link: ReadLink) -> Maybe<Void> {
        guard let memberID = self.authInfoProvider.signedInMemberID() else {
            return self.itemsRespoitory.updateLink(link)
        }
        let link = link |> \.ownerID .~ memberID
        return self.itemsRespoitory.requestUpdateLink(link)
    }
}


// MARKK: - ReadItemOptionsUsecase

extension ReadItemUsecaseImple {
    
    public func loadShrinkModeIsOnOption() -> Maybe<Bool> {
        return self.optionsRespository.fetchLastestsIsShrinkModeOn()
    }
    
    public func updateIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void> {
        return self.optionsRespository.updateIsShrinkModeOn(newvalue)
    }
}

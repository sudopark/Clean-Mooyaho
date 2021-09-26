//
//  ReadItemRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemRepository {
    
    func fetchMyItems() -> Maybe<[ReadItem]>
    
    func requestLoadMyItems(for memberID: String) -> Observable<[ReadItem]>
    
    func fetchCollectionItems(collectionID: String) -> Maybe<[ReadItem]>
    
    func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]>

    func updateCollection(_ collection: ReadCollection) -> Maybe<Void>
    
    func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void>
    
    func updateLink(_ link: ReadLink) -> Maybe<Void>
    
    func requestUpdateLink(_ link: ReadLink) -> Maybe<Void>
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection>
    
    func requestLoadCollection(for memberID: String, collectionID: String) -> Observable<ReadCollection>
}

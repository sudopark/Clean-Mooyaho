//
//  ShareItemRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ShareItemRepository {
    
    func requestShareCollection(_ collectionID: String) -> Maybe<SharedReadCollection>
    
    func requestStopShare(readCollection collectionID: String) -> Maybe<Void>
    
    func requestLoadMySharingCollectionIDs() -> Observable<[String]>
    
    func requestLoadLatestsSharedCollections() -> Observable<[SharedReadCollection]>
    
    func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection>
    
    func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection>
    
    func requestLoadSharedCollectionSubItems(collectionID: String) -> Maybe<[SharedReadItem]>
}

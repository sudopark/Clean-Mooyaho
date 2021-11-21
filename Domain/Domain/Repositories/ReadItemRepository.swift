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
    
    func requestLoadMyItems(for memberID: String?) -> Observable<[ReadItem]>
    
    func requestLoadCollectionItems(collectionID: String) -> Observable<[ReadItem]>

    func requestUpdateCollection(_ collection: ReadCollection) -> Maybe<Void>
        
    func requestUpdateLink(_ link: ReadLink) -> Maybe<Void>
    
    func requestLoadCollection(_ collectionID: String) -> Observable<ReadCollection>
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?>
    
    func requestRemove(item: ReadItem) -> Maybe<Void>
    
    func requestSearchReadItem(by keyword: String) -> Maybe<[SearchReadItemIndex]>
}

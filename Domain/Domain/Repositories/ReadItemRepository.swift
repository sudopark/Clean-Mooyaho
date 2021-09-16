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
    
    func requestLoadCollectionItems(for memberID: String?, collectionID: String) -> Observable<[ReadItem]>

    func requestUpdateCollection(for memberID: String?, collection: ReadCollection) -> Maybe<Void>
    
    func requestSaveLink(for memberID: String?, link: ReadLink) -> Maybe<Void>
}

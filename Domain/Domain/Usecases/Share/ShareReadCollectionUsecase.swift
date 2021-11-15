//
//  ShareReadCollectionUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ShareReadCollectionUsecase {
    
    func shareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection>
    
    func stopShare(collection collectionID: String) -> Maybe<Void>
    
    func refreshMySharingColletionIDs()
    
    var mySharingCollectionIDs: Observable<[String]> { get }
}

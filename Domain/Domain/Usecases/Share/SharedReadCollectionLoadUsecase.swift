//
//  SharedReadCollectionLoadUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol SharedReadCollectionLoadUsecase {
    
    func refreshLatestSharedReadCollection()
    
    var lastestSharedReadCollections: Observable<[SharedReadCollection]> { get }
    
    func loadMyharingCollection(for collectionID: String) -> Observable<SharedReadCollection>
}

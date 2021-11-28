//
//  FavoriteReadItemUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol FavoriteReadItemUsecas {
    
    func refreshFavoriteIDs() -> Maybe<[String]>
    
    func refreshSharedFavoriteIDs()
    
    func toggleFavorite(itemID: String, toOn: Bool) -> Maybe<Void>
    
    var sharedFavoriteItemIDs: Observable<[String]> { get }
}

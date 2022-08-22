//
//  FavoriteReadingListItemRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/08/15.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift


public protocol FavoriteReadingListItemRepository: Sendable {
    
    func loadFavoriteItemIDs() -> Observable<[String]>
    
    func toggleIsFavorite(_ id: String, isOn: Bool) async throws
}

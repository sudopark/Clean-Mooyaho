//
//  ReadItemOptionsUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

public enum ReadCollectionItemSortOrder: Equatable {
    case byCreatedAt(_ isAscending: Bool = false)
    case byLastUpdatedAt(_ isAscending: Bool = false)
    case byPriority(_ isAscending: Bool = false)
    case byCustomOrder
    
    public static var `default`: Self {
        return .byCreatedAt(false)
    }
}


public protocol ReadItemOptionsUsecase {
    
    func loadShrinkModeIsOnOption() -> Maybe<Bool>
    
    func updateIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void>
    
    func loadLatestSortOption(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder>
    
    func loadCustomOrder(for collectionID: String) -> Maybe<[String]>
    
    func updateSortOption(for collectionID: String,
                          to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
}

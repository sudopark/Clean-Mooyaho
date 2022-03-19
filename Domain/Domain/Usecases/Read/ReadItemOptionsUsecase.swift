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
        return .byCustomOrder
    }
}


public protocol ReadItemOptionsUsecase {
    
    var isShrinkModeOn: Observable<Bool> { get }
    
    func updateLatestIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void>
    
    var sortOrder: Observable<ReadCollectionItemSortOrder> { get }
    
    func updateLatestSortOption(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func reloadCustomOrder(for collectionID: String) -> Observable<[String]>
    
    func customOrder(for collectionID: String) -> Observable<[String]>
    
    func updateCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
    
    func isAddItemGuideEverShownWithMarking() -> Bool
}

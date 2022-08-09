//
//  ReadItemOptionsRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemOptionsRepository: Sendable {
    
    func fetchLastestsIsShrinkModeOn() -> Maybe<Bool?>
    
    func updateLatestIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void>
    
    func fetchLatestSortOrder() -> Maybe<ReadCollectionItemSortOrder?>
    
    func updateLatestSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>

    func requestLoadCustomOrder(for collectionID: String) -> Observable<[String]>
    
    func requestUpdateCustomSortOrder(for collectionID: String,
                                      itemIDs: [String]) -> Maybe<Void>
    
    func isAddItemGuideEverShownWithMarking() -> Bool
    
    func didWelComeItemAdded() -> Bool
    
    func updateDidWelcomeItemAdded()
}

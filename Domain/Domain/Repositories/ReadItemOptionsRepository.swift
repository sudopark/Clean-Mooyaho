//
//  ReadItemOptionsRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemOptionsRepository {
    
    func fetchLastestsIsShrinkModeOn() -> Maybe<Bool>
    
    func updateIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void>
    
    func fetchSortOrder(for collectionID: String) -> Maybe<ReadCollectionItemSortOrder?>
    
    func fetchCustomSortOrder(for collectionID: String) -> Maybe<[String]>
    
    func updateSortOrder(for collectionID: String,
                         to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func updateCustomSortOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
}

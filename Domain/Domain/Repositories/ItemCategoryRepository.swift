//
//  ItemCategoryRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/10/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ItemCategoryRepository {
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func suggestItemCategory(for memberID: String?, name: String) -> Maybe<SuggestCategoryCollection>
    
    func loadLatestCategories(for memberID: String?) -> Maybe<[SuggestCategory]>
    
//    func removeCategory(_ category: ItemCategory) -> Maybe<Void>
}

//
//  ItemCategoryRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/10/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Extensions


public protocol ItemCategoryRepository {
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func updateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void>
    
    func suggestItemCategory(name: String, cursor: String?) -> Maybe<SuggestCategoryCollection>
    
    func loadLatestCategories() -> Maybe<[SuggestCategory]>
    
    func requestLoadCategories(earilerThan creatTime: TimeStamp,
                               pageSize: Int) -> Maybe<[ItemCategory]>
    
    func requestDeleteCategory(_ itemID: String) -> Maybe<Void>
    
    func findCategory(_ name: String) -> Maybe<ItemCategory?>
}

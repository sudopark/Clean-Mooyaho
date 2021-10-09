//
//  RepositoryImple+ItemCategory.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ItemCategoryRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var categoryRemote: ItemCategoryRemote { get }
    var categoryLocal: ItemCategoryLocalStorage { get }
}

extension ItemCategoryRepository where Self: ItemCategoryRepositoryDefImpleDependency {
    
    public func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return self.categoryLocal.fetchCategories(ids)
    }
    
    public func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return .empty()
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.categoryLocal.updateCategories(categories)
    }
    
    public func suggestItemCategory(name: String, cursor: String?) -> Maybe<SuggestCategoryCollection> {
        let suggestFromRemote = self.categoryRemote.requestSuggestCategories(name, cursor: cursor)
        let suggestFromLocal = self.categoryLocal.suggestCategories(name)
            .map { SuggestCategoryCollection(query: name, categories: $0, cursor: nil) }
        return suggestFromRemote.ifEmpty(switchTo: suggestFromLocal)
    }
    
    public func loadLatestCategories() -> Maybe<[SuggestCategory]> {
        let loadFromRemote = self.categoryRemote.requestLoadLastestCategories()
        let loadFromLocal = self.categoryLocal.loadLatestCategories()
        return loadFromRemote.ifEmpty(switchTo: loadFromLocal)
    }
}

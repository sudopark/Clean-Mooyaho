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
        return self.categoryRemote.requestLoadCategories(ids)
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        let remoteUpdating = self.categoryRemote.requestUpdateCategories(categories)
        let updateLocals = { [weak self] in self?.categoryLocal.updateCategories(categories) ?? .empty() }
        return remoteUpdating.switchOr(append: updateLocals, witoutError: ())
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
    
    public func requestLoadCategories(earilerThan creatTime: TimeStamp,
                                      pageSize: Int) -> Maybe<[ItemCategory]> {
        
        let updateLocal: ([ItemCategory]) -> Void = { [weak self] categories in
            guard let self = self else { return }
            self.updateCategories(categories)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        let loadFromRemote = self.categoryRemote
            .requestLoadCategories(earilerThan: creatTime, pageSize: pageSize)
            .do(onNext: updateLocal)
                
        let loadFromLocal = self.categoryLocal
            .fetchCategories(earilerThan: creatTime, pageSize: pageSize)
        return loadFromRemote.ifEmpty(switchTo: loadFromLocal)
    }
    
    public func requestDeleteCategory(_ itemID: String) -> Maybe<Void> {
        let deleteFromRemote = self.categoryRemote.requestDeleteCategory(itemID)
        let deleteFromLocal = { [weak self] in self?.categoryLocal.deleteCategory(itemID) ?? .empty() }
        return deleteFromRemote.switchOr(append: deleteFromLocal, witoutError: ())
    }
}

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
}

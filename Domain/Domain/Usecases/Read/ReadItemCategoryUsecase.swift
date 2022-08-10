//
//  ReadItemCategoryUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics
import Extensions


// MARK: - ReadItemCategoryUsecase

public struct SameNameCategoryExistsError: Error {
    public init () { }
}

public struct UpdateCategoryAttrParams {
    
    public let uid: String
    public var newName: String?
    public var newColorCode: String?
    
    public init(uid: String) {
        self.uid = uid
    }
    
    public var isNothingChanged: Bool {
        return self.newName == nil && self.newColorCode == nil
    }
}

public protocol ReadItemCategoryUsecase: Sendable, AnyObject {
    
    func categories(for ids: [String]) -> Observable<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func updateCategory(by params: UpdateCategoryAttrParams,
                        from: ItemCategory) -> Maybe<ItemCategory>
    
    func loadCategories(earilerThan createTime: TimeStamp) -> Maybe<[ItemCategory]>
    
    func deleteCategory(_ itemID: String) -> Maybe<Void>
}

extension ReadItemCategoryUsecase {
    
    public func makeCategory(_ name: String, colorCode: String) -> Maybe<ItemCategory> {
        let newCatetory = ItemCategory(name: name, colorCode: colorCode)
        return self.updateCategories([newCatetory])
            .map { newCatetory }
    }
}


// MARK: - ReadItemCategoryUsecaseImple

public final class ReadItemCategoryUsecaseImple: ReadItemCategoryUsecase {

    private let repository: ItemCategoryRepository
    private let sharedService: SharedDataStoreService
    
    private let disposeBag = DisposeBag()
    
    public init(repository: ItemCategoryRepository,
                sharedService: SharedDataStoreService) {
        self.repository = repository
        self.sharedService = sharedService
    }
}


extension ReadItemCategoryUsecaseImple {
    
    private var sharedKey: SharedDataKeys {
        return SharedDataKeys.categoriesMap
    }
    
    public func categories(for ids: [String]) -> Observable<[ItemCategory]> {
        
        let localFetching: ([String]) -> Maybe<[ItemCategory]> = { [weak self] ids in
            return self?.repository.fetchCategories(ids) ?? .empty()
        }
        let remoteLoading: ([String]) -> Maybe<[ItemCategory]> = { [weak self] ids in
            return self?.repository.requestLoadCategories(ids) ?? .empty()
        }
        let key = SharedDataKeys.categoriesMap.rawValue
        return self.sharedService
            .observeValuesInMappWithSetup(ids: ids, sharedKey: key, disposeBag: self.disposeBag,
                                    idSelector: { $0.uid },
                                    localFetchinig: localFetching,
                                    remoteLoading: remoteLoading)
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        
        return self.repository.updateCategories(categories)
            .do(onNext: { [weak self] in
                self?.updateOnStore(categories)
            })
    }
    
    public func updateCategory(by params: UpdateCategoryAttrParams,
                               from: ItemCategory) -> Maybe<ItemCategory> {
        
        if params.isNothingChanged {
            return .just(from)
        }
        
        let findSameNameCategorysIsExistsIfNeed: Maybe<ItemCategory?> = params.newName
            .map { self.findcategory(by: $0) } ?? .just(nil)
        
        let errorWhenSameNameCategoryExists: (ItemCategory?) throws -> Void = { category in
            if category != nil {
                throw SameNameCategoryExistsError()
            }
        }
        
        let thenUpdateCategory: () -> Maybe<ItemCategory> = { [weak self] in
            guard let self = self else { return .empty() }
            let newCategory = from.applyingChange(params)
            return self.repository.updateCategory(by: params).map { newCategory }
        }
        
        let updateStore: (ItemCategory) -> Void = { [weak self] category in
            guard let self = self else { return }
            let datKey = SharedDataKeys.categoriesMap.rawValue
            self.sharedService.update([String: ItemCategory].self, key: datKey) {
                return ($0 ?? [:]) |> key(category.uid) .~ category
            }
        }
        
        return findSameNameCategorysIsExistsIfNeed
            .map(errorWhenSameNameCategoryExists)
            .flatMap(thenUpdateCategory)
            .do(onNext: updateStore)
    }
    
    private func findcategory(by name: String) -> Maybe<ItemCategory?> {
        
        let itemFromStore = self.findSameNameCategoryExistsOnStore(name)
        
        let updateStoreIfPosible: (ItemCategory?) -> Void = { [weak self] category in
            guard let category = category else { return }
            let datKey = SharedDataKeys.categoriesMap.rawValue
            self?.sharedService.update([String: ItemCategory].self, key: datKey) {
                return ($0 ?? [:]) |> key(category.uid) .~ category
            }
            
        }
        let orFindFromRepository = self.repository.findCategory(name)
            .do(onNext: updateStoreIfPosible)
                
        return itemFromStore.map { .just($0) } ?? orFindFromRepository
    }
    
    private func findSameNameCategoryExistsOnStore(_ name: String) -> ItemCategory? {
        return self.sharedService
            .fetch([String: ItemCategory].self, key: .categoriesMap)?
            .values
            .first(where: { $0.name == name })
    }
    
    public func loadCategories(earilerThan createTime: TimeStamp) -> Maybe<[ItemCategory]> {
        return self.repository.requestLoadCategories(earilerThan: createTime, pageSize: 30)
            .do(onNext: { [weak self] categories in
                self?.updateOnStore(categories)
            })
    }
    
    public func deleteCategory(_ itemID: String) -> Maybe<Void> {
        
        let removeFromStore: () -> Void = { [weak self] in
            guard let self = self else { return }
            let datKey = SharedDataKeys.categoriesMap.rawValue
            self.sharedService.update([String: ItemCategory].self, key: datKey) {
                return ($0 ?? [:]) |> key(itemID) .~ nil
            }
        }
        
        return self.repository.requestDeleteCategory(itemID)
            .do(onNext: removeFromStore)
    }
    
    private func updateOnStore(_ categories: [ItemCategory]) -> Void {
        let datKey = SharedDataKeys.categoriesMap.rawValue
        self.sharedService.update([String: ItemCategory].self, key: datKey) {
            return categories.reduce($0 ?? [:]) { $0 |> key($1.uid) .~ $1 }
        }
    }
}

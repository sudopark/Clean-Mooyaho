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


// MARK: - ReadItemCategoryUsecase

public struct SameNameCategoryExistsError: Error {
    public init () { }
}

public protocol ReadItemCategoryUsecase: AnyObject {
    
    func categories(for ids: [String]) -> Observable<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func updateCategoryIfNotExist(_ category: ItemCategory) -> Maybe<Void>
    
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
    
    public func updateCategoryIfNotExist(_ category: ItemCategory) -> Maybe<Void> {
        return .empty()
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

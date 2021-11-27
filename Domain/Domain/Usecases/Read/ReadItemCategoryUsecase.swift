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

public protocol ReadItemCategoryUsecase: AnyObject {
    
    func categories(for ids: [String]) -> Observable<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
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
        
        let updateOnStore: () -> Void = { [weak self] in
            guard let self = self else { return }
            let datKey = SharedDataKeys.categoriesMap.rawValue
            self.sharedService.update([String: ItemCategory].self, key: datKey) {
                return categories.reduce($0 ?? [:]) { $0 |> key($1.uid) .~ $1 }
            }
        }
        
        return self.repository.updateCategories(categories)
            .do(onNext: updateOnStore)
    }
}

//
//  CategoryUsecase+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/27.
//

import Foundation

import RxSwift

import Domain


// MARK: - ItemCategoryPresentable

public protocol ItemCategoryPresentable {
 
    var categoryIDs: [String] { get }
}

extension ReadCollection: ItemCategoryPresentable { }
extension ReadLink: ItemCategoryPresentable { }
extension SharedReadCollection: ItemCategoryPresentable { }
extension SharedReadLink: ItemCategoryPresentable { }
extension SearchReadItemIndex: ItemCategoryPresentable { }


// MARK: - load requireCategoryMap

extension ReadItemCategoryUsecase {
    
    public func requireCategoryMap(
        from sources: [Observable<[ItemCategoryPresentable]>]
    ) -> Observable<[String: ItemCategory]> {
    
        let requeireIDsSet = sources.totalCategoryIDsSet()
        return self.loadCategories(from: requeireIDsSet)
    }
    
    public func requireCategoryMap(
        from sourceIDs: Observable<[String]>
    ) -> Observable<[String: ItemCategory]> {
        
        let idsSet = sourceIDs.map { Set($0) }
        return self.loadCategories(from: idsSet)
    }
    
    private func loadCategories(
        from idsSetSource: Observable<Set<String>>
    ) -> Observable<[String: ItemCategory]> {
        
        let loadCategories: (Set<String>) -> Observable<[ItemCategory]> = { [weak self] idsSet in
            return self?.categories(for: Array(idsSet)) ?? .empty()
        }
        let asDictionary: ([ItemCategory]) -> [String: ItemCategory] = { categories in
            return categories.reduce(into: [String: ItemCategory]()) { $0[$1.uid] = $1 }
        }
        return idsSetSource
            .distinctUntilChanged()
            .flatMapLatest(loadCategories)
            .map(asDictionary)
    }
}

private extension Array where Element: Observable<[ItemCategoryPresentable]> {
    
    func totalCategoryIDsSet() -> Observable<Set<String>> {
        let mergedCategoruIDs = Observable.merge(self).map { $0.flatMap { $0.categoryIDs } }
        let foldAsSet: (Set<String>, [String]) -> Set<String> = { acc, ids in
            return  acc.union(ids)
        }
        return mergedCategoruIDs
            .scan(Set<String>(), accumulator: foldAsSet)
    }
}

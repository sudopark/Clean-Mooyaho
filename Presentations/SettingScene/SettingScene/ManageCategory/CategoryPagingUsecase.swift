//
//  CategoryPagingUsecase.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/03.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain
import Extensions


// MARK: - CategoryLoadParamter

public struct CategoryLoadParamter: SuggestReqParamType {
    
    public typealias Cursor = TimeStamp?
    public var isEmpty: Bool { self.cursorTime == nil }
    
    let cursorTime: TimeStamp?
    init(cursorTime: TimeStamp?) {
        self.cursorTime = cursorTime
    }
    
    public func updateNextPageCursor(_ cursor: TimeStamp?) -> CategoryLoadParamter {
        return .init(cursorTime: cursorTime)
    }
}


// MARK: - CategoryLoadResult

public struct CategoryLoadResult: SuggestResultCollectionType {
    
    let categories: [ItemCategory]
    
    public typealias Cursor = TimeStamp?
    
    public let query: String = "paging"
    
    public var nextPageCursor: Cursor?
    
    init(categories: [ItemCategory], cursor: TimeStamp?) {
        self.categories = categories
        self.nextPageCursor = cursor
    }
    
    public func append(_ next: CategoryLoadResult) -> CategoryLoadResult {
        let nextPageCursor = next.categories.last?.createdAt
        return .init(categories: self.categories + next.categories, cursor: nextPageCursor)
    }
    
    public static func distinguisForSuggest(_ lhs: CategoryLoadResult, _ rhs: CategoryLoadResult) -> Bool {
        return lhs.nextPageCursor == rhs.nextPageCursor
            && lhs.categories.map { $0.uid } == rhs.categories.map { $0.uid }
    }
}


// MARK: - CategoryPageLoadUsecase

public protocol CategoryPageLoadUsecase {
    
    func refreshList()
    func loadMore()
    
    var categories: Observable<[ItemCategory]> { get }
}


public final class CategoryPageLoadUsecaseImple: CategoryPageLoadUsecase {
    
    private let categoryUsecase: ReadItemCategoryUsecase
    private var internalUsecase: SuggestUsecase<CategoryLoadParamter, CategoryLoadResult>!
    
    init(categoryUsecase: ReadItemCategoryUsecase, throttleInterval: Int = 500) {
        self.categoryUsecase = categoryUsecase
        self.internalUsecase = .init(throttleInterval: throttleInterval) { [weak self] params in
            return self?.loadCateogries(params).asObservable() ?? .empty()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private func loadCateogries(_ params: CategoryLoadParamter) -> Maybe<CategoryLoadResult> {
        guard let time = params.cursorTime else { return .empty() }
        
        let asResult: ([ItemCategory]) -> CategoryLoadResult = { categories in
            return .init(categories: categories, cursor: categories.last?.createdAt)
        }
        
        return self.categoryUsecase.loadCategories(earilerThan: time)
            .map(asResult)
        
    }
}

extension CategoryPageLoadUsecaseImple {
    
    public func refreshList() {
        let firstParams = CategoryLoadParamter(cursorTime: .now())
        self.internalUsecase.startSuggest(firstParams)
    }
    
    public func loadMore() {
        self.internalUsecase.suggestMore()
    }
}

extension CategoryPageLoadUsecaseImple {
    
    public var categories: Observable<[ItemCategory]> {
        return self.internalUsecase.suggestResult
            .map { $0?.categories ?? [] }
    }
}

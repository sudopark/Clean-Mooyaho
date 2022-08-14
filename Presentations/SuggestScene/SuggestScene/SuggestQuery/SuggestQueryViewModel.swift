//
//  SuggestQueryViewModel.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - SuggestQueryViewModel

public struct SuggestQueryCellViewModel {
    let queryText: String
    var latestSearchText: String?
    
    var isLatestSearched: Bool { self.latestSearchText != nil }
    
    init(query: SuggestQuery) {
        self.queryText = query.text
        self.latestSearchText = (query as? LatestSearchedQuery)?.searchedTime.timeAgoText
    }
}

public protocol SuggestQueryViewModel: AnyObject, Sendable {

    // interactor
    func suggest(with text: String)
    func selectQuery(_ query: String)
    func removeLatestSearchQuery(_ query: String)
    
    // presenter
    var resultIsEmpty: Observable<Bool> { get }
    var cellViewModels: Observable<[SuggestQueryCellViewModel]> { get }
}


// MARK: - SuggestQueryViewModelImple

public final class SuggestQueryViewModelImple: SuggestQueryViewModel, @unchecked Sendable {
    
    private let suggestQueryUsecase: SuggestQueryUsecase
    private let router: SuggestQueryRouting
    private weak var listener: SuggestQuerySceneListenable?
    
    public init(suggestQueryUsecase: SuggestQueryUsecase,
                router: SuggestQueryRouting,
                listener: SuggestQuerySceneListenable?) {
        
        self.suggestQueryUsecase = suggestQueryUsecase
        self.router = router
        self.listener = listener
        
        self.bindSuggestResults()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        
        let cellViewModels = BehaviorSubject<[SuggestQueryCellViewModel]?>(value: [])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindSuggestResults() {
        
        let asCellViewMdoel: ([SuggestQuery]) -> [SuggestQueryCellViewModel]
        asCellViewMdoel = { queries in
            return queries.map { SuggestQueryCellViewModel(query: $0) }
        }
        
        self.suggestQueryUsecase.suggestingQuery
            .map(asCellViewMdoel)
            .subscribe(onNext: { [weak self] cellViewModels in
                self?.subjects.cellViewModels.onNext(cellViewModels)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SuggestQueryViewModelImple Interactor

extension SuggestQueryViewModelImple {
    
    public func suggest(with text: String) {
        self.suggestQueryUsecase.startSuggest(query: text)
    }
    
    public func selectQuery(_ query: String) {
        self.listener?.suggestQuery(didSelect: query)
    }
    
    public func removeLatestSearchQuery(_ query: String) {
        self.suggestQueryUsecase.removeSearchedQuery(query)
    }
}


// MARK: - SuggestQueryViewModelImple Presenter

extension SuggestQueryViewModelImple {
 
    public var cellViewModels: Observable<[SuggestQueryCellViewModel]> {
        
        return self.subjects.cellViewModels
            .compactMap { $0 }
    }
    
    public var resultIsEmpty: Observable<Bool> {
        return self.subjects.cellViewModels
            .compactMap { $0 }
            .map { $0.isEmpty }
            .distinctUntilChanged()
    }
}

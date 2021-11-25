//
//  SuggestQueryUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


// MARK: - SuggestQueryUsecase

public protocol SuggestQueryUsecase {
    
    func startSuggest(query: String)
    
    var suggestingQuery: Observable<[SuggestQuery]> { get }
    
    func removeSearchedQuery(_ query: String)
}


// MARK: - SuggestableQuerySyncUsecase

public protocol SuggestableQuerySyncUsecase {

    func insertSuggestableQueries(_ queries: [String])
}


public final class SuggestQueryUsecaseImple: SuggestQueryUsecase, SuggestableQuerySyncUsecase {
    
    private let suggestQueryEngine: SuggestQueryEngine
    private let searchRepository: IntegratedSearchReposiotry
    
    public init(suggestQueryEngine: SuggestQueryEngine,
                searchRepository: IntegratedSearchReposiotry) {
        
        self.suggestQueryEngine = suggestQueryEngine
        self.searchRepository = searchRepository
        
        self.prepareLatestSearchKeyword()
        self.prepareSuggestableQueries()
    }
    
    private let disposeBag: DisposeBag = .init()
    private let searchingKeyword = BehaviorSubject<String?>(value: nil)
    private let latestSearchedQueries = BehaviorRelay<[LatestSearchedQuery]?>(value: nil)
    
    private func prepareLatestSearchKeyword() {
        
        let update: ([LatestSearchedQuery]) -> Void = { [weak self] queries in
            self?.latestSearchedQueries.accept(queries)
        }
        self.searchRepository.fetchLatestSearchQueries()
            .subscribe(onSuccess: update)
            .disposed(by: self.disposeBag)
    }
    
    private func prepareSuggestableQueries() {
        
        let setupEngine: ([String]) -> Void = { [weak self] queries in
            self?.suggestQueryEngine.insertTokens(queries)
        }
        self.searchRepository.fetchAllSuggestableQueries()
            .subscribe(onSuccess: setupEngine)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - suggest

extension SuggestQueryUsecaseImple {
    
    public func startSuggest(query: String) {
        self.searchingKeyword.onNext(query)
    }
    
    public var suggestingQuery: Observable<[SuggestQuery]> {
        
        let switchSource: (String) -> Observable<[SuggestQuery]> = { [weak self] keyword in
            guard let self = self else { return .empty() }
            return keyword.isEmpty
                ? self.defaultLatestSearchedQuerues()
                : self.suggestQueries(by: keyword).asObservable()
        }
        
        return self.searchingKeyword
            .compactMap { $0 }
            .flatMapLatest(switchSource)
            .distinctUntilChanged { $0.map { $0.customCompareKey } }
    }
    
    private func defaultLatestSearchedQuerues() -> Observable<[SuggestQuery]> {
        return self.latestSearchedQueries
            .compactMap { $0 }
    }
    
    private func suggestQueries(by keyword: String) -> Maybe<[SuggestQuery]> {
        return self.suggestQueryEngine.suggestSearchQuery(by: keyword)
            .catchAndReturn([])
            .map { $0.map { MayBeSearchableQuery(text: $0) } }
    }
    
    public func removeSearchedQuery(_ query: String) {
        let updateLatestList: () -> Void = { [weak self] in
            guard let self = self else { return }
            let newQueries = self.latestSearchedQueries.value?.filter { $0.text != query }
            self.latestSearchedQueries.accept(newQueries)
        }
        
        self.searchRepository.removeLatestSearchQuery(query)
            .catchAndReturn(())
            .subscribe(onSuccess: updateLatestList)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - sync

extension SuggestQueryUsecaseImple {
    
    public func insertSuggestableQueries(_ queries: [String]) {
        let updateEngine: () -> Void = { [weak self] in
            self?.suggestQueryEngine.insertTokens(queries)
        }
        self.searchRepository.insertSuggetableQueries(queries)
            .subscribe(onSuccess: updateEngine)
            .disposed(by: self.disposeBag)
    }
}

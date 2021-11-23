//
//  SearchReadItemUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics


public protocol SuggestReadItemUsecase {
    
    func startSuggest(query: String)
    
    var suggestingQuery: Observable<[SuggestQuery]> { get }
    
    func search(query: String) -> Maybe<[SearchReadItemIndex]>
    
    func removeLatestSearchedQuery(_ query: String)
}


public final class SuggestReadItemUsecaseImple: SuggestReadItemUsecase {
    
    private let searchQueryStoraService: SearchableQueryTokenStoreService
    private let searchRepository: IntegratedSearchReposiotry
    
    public init(searchQueryStoraService: SearchableQueryTokenStoreService,
                searchRepository: IntegratedSearchReposiotry) {
        
        self.searchQueryStoraService = searchQueryStoraService
        self.searchRepository = searchRepository
        
        self.prepareLatestSearchKeyword()
    }
    
    private let dipsoseBag: DisposeBag = .init()
    private let searchingKeyword = BehaviorSubject<String?>(value: nil)
    private let latestSearchedQueries = BehaviorRelay<[LatestSearchedQuery]?>(value: nil)
    
    private func prepareLatestSearchKeyword() {
        
        let update: ([LatestSearchedQuery]) -> Void = { [weak self] queries in
            self?.latestSearchedQueries.accept(queries)
        }
        self.searchRepository.fetchLatestSearchQueries()
            .subscribe(onSuccess: update)
            .disposed(by: self.dipsoseBag)
    }
}


extension SuggestReadItemUsecaseImple {
    
    public func startSuggest(query: String) {
        self.searchingKeyword.onNext(query)
    }
}


extension SuggestReadItemUsecaseImple {
    
    public var suggestingQuery: Observable<[SuggestQuery]> {
        
        let switchSource: (String) -> Observable<[SuggestQuery]> = { [weak self] keyword in
            guard let self = self else { return .empty() }
            return keyword.isEmpty
                ? self.latestSearchedQueries.compactMap { $0 }
                : self.suggestQueries(by: keyword).asObservable()
        }
        
        return self.searchingKeyword
            .compactMap { $0 }
            .flatMapLatest(switchSource)
            .distinctUntilChanged { $0.map { $0.customCompareKey } }
    }
    
    private func suggestQueries(by keyword: String) -> Maybe<[SuggestQuery]> {
        return self.searchQueryStoraService.suggestSearchQuery(by: keyword)
            .catchAndReturn([])
            .map { $0.map { MayBeSearchableQuery(text: $0) } }
    }
    
    public func search(query: String) -> Maybe<[SearchReadItemIndex]> {
        
        let updateToken: ([SearchReadItemIndex]) -> Void = { [weak self] _ in
            self?.searchQueryStoraService.insertTokens(query)
            self?.insertAtLatestSearch(query: query)
        }
        
        return self.searchRepository.requestSearchReadItem(by: query)
            .do(onNext: updateToken)
    }
    
    private func insertAtLatestSearch(query: String) {
        let new = LatestSearchedQuery(text: query, time: .now())
        let queries = [new] + (self.latestSearchedQueries.value?.filter { $0.text != query } ?? [])
        self.latestSearchedQueries.accept(queries)
    }
    
    public func removeLatestSearchedQuery(_ query: String) {

        let updateLatestList: () -> Void = { [weak self] in
            guard let self = self else { return }
            let newQueries = self.latestSearchedQueries.value?.filter { $0.text != query }
            self.latestSearchedQueries.accept(newQueries)
            
            self.searchQueryStoraService.removeToken(query)
        }
        
        self.searchRepository.removeLatestSearchQuery(query)
            .catchAndReturn(())
            .subscribe(onSuccess: updateLatestList)
            .disposed(by: self.dipsoseBag)
    }
}

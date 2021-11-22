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
    
    var suggestingQuery: Observable<[String]> { get }
    
    func search(query: String) -> Maybe<[SearchReadItemIndex]>
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
    private let latestSearchedQueries = BehaviorRelay<[String]?>(value: nil)
    
    private func prepareLatestSearchKeyword() {
        
        let update: ([String]) -> Void = { [weak self] queries in
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
    
    public var suggestingQuery: Observable<[String]> {
        
        let switchSource: (String) -> Observable<[String]> = { [weak self] keyword in
            guard let self = self else { return .empty() }
            return keyword.isEmpty
                ? self.latestSearchedQueries.compactMap { $0 }
                : self.suggestQueries(by: keyword).asObservable()
        }
        
        return self.searchingKeyword
            .compactMap { $0 }
            .flatMapLatest(switchSource)
            .distinctUntilChanged()
    }
    
    private func suggestQueries(by keyword: String) -> Maybe<[String]> {
        return self.searchQueryStoraService.suggestSearchQuery(by: keyword)
            .catchAndReturn([])
    }
    
    public func search(query: String) -> Maybe<[SearchReadItemIndex]> {
        
        let updateToken: ([SearchReadItemIndex]) -> Void = { [weak self] _ in
            self?.searchQueryStoraService.insertTokens(query)
        }
        
        return self.searchRepository.requestSearchReadItem(by: query)
            .do(onNext: updateToken)
    }
}

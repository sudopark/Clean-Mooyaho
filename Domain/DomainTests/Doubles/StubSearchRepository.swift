//
//  StubSearchRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/11/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubSearchRepository: IntegratedSearchReposiotry {

    var searchResult: Result<[SearchReadItemIndex], Error> = .success([])
    func requestSearchReadItem(by keyword: String) -> Maybe<[SearchReadItemIndex]> {
        return searchResult.asMaybe()
    }

    var lastestQueries: [LatestSearchedQuery] = []
    func fetchLatestSearchQueries() -> Maybe<[LatestSearchedQuery]> {
        return .just(self.lastestQueries)
    }

    func removeLatestSearchQuery(_ query: String) -> Maybe<Void> {
        return .just()
    }
    
    var didDownloaded: Bool = false
    func downnloadAllSuggestableQueries() -> Maybe<Void> {
        self.didDownloaded = true
        return .just()
    }
    
    var suggestableQueries: [String] = []
    func fetchAllSuggestableQueries() -> Maybe<[String]> {
        return .just(self.suggestableQueries)
    }
    
    var didInsertedSuggestableQueris: [String]?
    func insertSuggetableQueries(_ queries: [String]) -> Maybe<Void> {
        self.didInsertedSuggestableQueris = queries
        return .just()
    }
}

//
//  StubIntegratedSearchUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/11/24.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import UnitTestHelpKit


open class StubIntegratedSearchUsecase: IntegratedSearchUsecase {
    
    public init() { } 
    
    public var latestsQueries: [LatestSearchedQuery] = []
    public var mayBeSearchableQueryMap: [String: [MayBeSearchableQuery]] = [:]
    
    private let fakeQueries = PublishSubject<[SuggestQuery]>()
    
    public func startSuggest(query: String) {
        if query.isEmpty {
            self.fakeQueries.onNext(self.latestsQueries)
        } else {
            let queries = self.mayBeSearchableQueryMap[query] ?? []
            self.fakeQueries.onNext(queries)
        }
    }
    
    public var suggestingQuery: Observable<[SuggestQuery]> {
        return self.fakeQueries
            .asObservable()
    }
    
    public func removeLatestSearchedQuery(_ query: String) {
        self.latestsQueries.removeAll(where:  { $0.text == query })
    }
    
    public var searchResultMocking: PublishSubject<[SearchReadItemIndex]>?
    public var searchReadItemResult: Result<[SearchReadItemIndex], Error> = .success([])
    public func search(query: String) -> Maybe<[SearchReadItemIndex]> {
        
        if let mocking = self.searchResultMocking {
            return mocking.asMaybe()
        }
        
        return self.searchReadItemResult.asMaybe()
    }
}

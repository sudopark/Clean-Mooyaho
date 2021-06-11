//
//  StubSearchNewPlaceUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/06/11.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class StubSearchNewPlaceUsecase: SearchNewPlaceUsecase, Stubbable {
    
    public init() {}
    
    open func startSearchPlace(for query: SuggestPlaceQuery, in location: UserLocation) {
        let result = self.resolve(SearchingPlaceCollection.self, key: "startSearchPlace:\(query.string)")
        self.stubResult.onNext(result)
    }
    
    open func finishSearchPlace() {
        self.stubResult.onNext(nil)
    }
    
    open func loadMorePlaceSearchResult() {
        let result = self.resolve(SearchingPlaceCollection.self, key: "loadMorePlaceSearchResult")
        self.stubResult.onNext(result)
    }
    
    private let stubResult = PublishSubject<SearchingPlaceCollection?>()
    open var newPlaceSearchResult: Observable<SearchingPlaceCollection?> {
        return self.stubResult
    }
}

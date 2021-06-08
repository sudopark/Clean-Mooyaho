//
//  StubSuggestPlaceUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/06/09.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class StubSuggestPlaceUsecase: SuggestPlaceUsecase, Stubbable {
    
    public init() {}
    
    open func startSuggestPlace(for query: SuggestPlaceQuery, in location: UserLocation) {
        
        let result = self.resolve(SuggestPlaceResult.self, key: "startSuggestPlace:\(query.string)")
        self.stubSuggestResult.onNext(result)
    }
    
    open func finishPlaceSuggesting() {
        self.stubSuggestResult.onNext(nil)
    }
    
    open func loadMoreSuggestPages() {
        let result = self.resolve(SuggestPlaceResult.self, key: "loadMoreSuggestPages")
        self.stubSuggestResult.onNext(result)
    }
    
    private let stubSuggestResult = PublishSubject<SuggestPlaceResult?>()
    open var placeSuggestResult: Observable<SuggestPlaceResult?> {
        return self.stubSuggestResult.asObservable()
    }
}

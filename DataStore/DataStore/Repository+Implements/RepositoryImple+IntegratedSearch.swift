//
//  RepositoryImple+IntegratedSearch.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol IntegratedSearchReposiotryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var readItemRemote: ReadItemRemote { get }
    var readItemLocal: ReadItemLocalStorage { get }
    var searchLocal: SearchLocalStorage { get }
}

extension IntegratedSearchReposiotry where Self: IntegratedSearchReposiotryDefImpleDependency {
    
    public func requestSearchReadItem(by keyword: String) -> Maybe<[SearchReadItemIndex]> {
        let suggestOnRemote = self.readItemRemote.requestSearchItem(keyword)
        let suggestOnLocal = self.readItemLocal.searchReadItems(keyword)
        
        let updateLatestSearchQuery: ([SearchReadItemIndex]) -> Void = { [weak self] _ in
            self?.updateLatestSearchQuery(keyword)
        }
        
        return suggestOnRemote.ifEmpty(switchTo: suggestOnLocal)
            .do(onNext: updateLatestSearchQuery)
    }
    
    public func fetchLatestSearchQueries() -> Maybe<[LatestSearchedQuery]> {
        return self.searchLocal.fetchLatestSearchedQueries()
    }
    
    private func updateLatestSearchQuery(_ query: String) {
        
        self.searchLocal.insertLatestSearchQuery(query)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func removeLatestSearchQuery(_ query: String) -> Maybe<Void> {
        return self.searchLocal.removeLatestSearchQuery(query)
    }
}

//
//  IntegratedSearchUsecase.swift
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


// MARK: - SearchReadItemUsecase

public protocol SearchReadItemUsecase {
    
    func search(query: String) -> Maybe<[SearchReadItemIndex]>
}


// MARK: - IntegratedSearchUsecase

public protocol IntegratedSearchUsecase: SearchReadItemUsecase { }

public final class IntegratedSearchUsecaseImple: IntegratedSearchUsecase {
    
    private let suggestQuerySyncUsecase: SuggestableQuerySyncUsecase
    private let searchRepository: IntegratedSearchReposiotry
    
    public init(suggestQuerySyncUsecase: SuggestableQuerySyncUsecase,
                searchRepository: IntegratedSearchReposiotry) {
        
        self.suggestQuerySyncUsecase = suggestQuerySyncUsecase
        self.searchRepository = searchRepository
    }
}


// MARK: - search

extension IntegratedSearchUsecaseImple {
    
    public func search(query: String) -> Maybe<[SearchReadItemIndex]> {
        
        let updateSuggestableQueries: ([SearchReadItemIndex]) -> Void = { [weak self] result in
            self?.suggestQuerySyncUsecase.insertLatestSearchQuery(query)
            guard let self = self, result.isNotEmpty else { return }
            let queries = [query] + result.map { $0.displayName }
            self.suggestQuerySyncUsecase.insertSuggestableQueries(queries)
        }
        
        return self.searchRepository.requestSearchReadItem(by: query)
            .do(onNext: updateSuggestableQueries)
    }
}

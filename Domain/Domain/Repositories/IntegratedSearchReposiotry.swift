//
//  IntegratedSearchReposiotry.swift
//  Domain
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol IntegratedSearchReposiotry {
    
    func requestSearchReadItem(by keyword: String) -> Maybe<[SearchReadItemIndex]>
    
    func fetchLatestSearchQueries() -> Maybe<[LatestSearchedQuery]>
    
    func removeLatestSearchQuery(_ query: String) -> Maybe<Void>
}

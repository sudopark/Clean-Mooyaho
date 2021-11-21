//
//  SearchReadItemUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


public protocol SuggestReadItemUsecase {
    
    func startSuggest(query: String)
    
    var searchResult: Observable<[SearchReadItemIndex]> { get }
}

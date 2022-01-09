//
//  StubReadLinkAddSuggestUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/31.
//

import Foundation

import RxSwift

import Domain

open class StubReadLinkAddSuggestUsecase: ReadLinkAddSuggestUsecase {
    
    public var url: String?
    
    public init() { }
    
    public func loadSuggestAddNewItemByURLExists() -> Maybe<String?> {
        return .just(url)
    }
}

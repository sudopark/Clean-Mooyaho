//
//  StubMemoUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/10/24.
//

import Foundation

import RxSwift

import Domain


open class StubMemoUsecase: ReadLinkMemoUsecase {
    
    public init() {}
    
    public var memo: ReadLinkMemo?
    public func loadMemo(for linkItemID: String) -> Observable<ReadLinkMemo?> {
        return .just(memo)
    }
    
    public func updateMemo(_ memo: ReadLinkMemo) -> Maybe<Void> {
        return .just()
    }
    
    public func deleteMemo(for linkItemID: String) -> Maybe<Void> {
        return .just()
    }
}

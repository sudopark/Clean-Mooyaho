//
//  ReadLinkMemoUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadLinkMemoUsecase {
    
    func loadMemo(for linkItemID: String) -> Observable<ReadLinkMemo?>
    
    func updateMemo(_ memo: ReadLinkMemo) -> Maybe<Void>
    
    func deleteMemo(for linkItemID: String) -> Maybe<Void>
}


public final class ReadLinkMemoUsecaseImple: ReadLinkMemoUsecase {
    
    private let repository: ReadLinkMemoRepository
    
    public init(repository: ReadLinkMemoRepository) {
        self.repository = repository
    }
}


extension ReadLinkMemoUsecaseImple {
    
    public func loadMemo(for linkItemID: String) -> Observable<ReadLinkMemo?> {
        return self.repository.requestLoadMemo(for: linkItemID)
    }
    
    public func updateMemo(_ memo: ReadLinkMemo) -> Maybe<Void> {
        return self.repository.requestUpdateMemo(memo)
    }
    
    public func deleteMemo(for linkItemID: String) -> Maybe<Void> {
        return self.repository.requestRemoveMemo(for: linkItemID)
    }
}

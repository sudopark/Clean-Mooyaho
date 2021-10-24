//
//  StubReadLinkMemoRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubReadLinkMemoRepository: ReadLinkMemoRepository {
    
    func requestLoadMemo(for linkItemID: String) -> Observable<ReadLinkMemo?> {
        return .just(.dummyID(linkItemID))
    }
    
    func requestUpdateMemo(_ memo: ReadLinkMemo) -> Maybe<Void> {
        return .just()
    }
    
    func requestRemoveMemo(for linkItemID: String) -> Maybe<Void> {
        return .just()
    }
}

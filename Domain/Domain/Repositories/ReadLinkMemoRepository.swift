//
//  ReadLinkMemoRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadLinkMemoRepository: Sendable {
    
    func requestLoadMemo(for linkItemID: String) -> Observable<ReadLinkMemo?>
    
    func requestUpdateMemo(_ memo: ReadLinkMemo) -> Maybe<Void>
    
    func requestRemoveMemo(for linkItemID: String) -> Maybe<Void>
}

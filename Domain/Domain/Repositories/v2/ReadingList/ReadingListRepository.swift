//
//  ReadingListRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/07/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift

public protocol ReadingListRepository: Sendable {
    
    func loadMyList() -> Observable<ReadingList>
    
    func loadList(_ listID: String) -> Observable<ReadingList>
    
    func loadLinkItem(_ itemID: String) -> Observable<ReadLinkItem>
    
    func saveList(_ readingList: ReadingList,
                  at parentListID: String?) async throws -> ReadingList
    
    func updateList(_ readingList: ReadingList) async throws -> ReadingList
    
    func saveLinkItem(_ item: ReadLinkItem,
                      to listID: String?) async throws -> ReadLinkItem
    
    func updateLinkItem(_ item: ReadLinkItem) async throws -> ReadLinkItem
    
    func removeList(_ id: String) async throws
    
    func removeLinkItem(_ id: String) async throws
}

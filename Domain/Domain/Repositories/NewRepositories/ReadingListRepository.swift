//
//  ReadingListRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/07/01.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol ReadingListRepository {
    
    func loadMyList(for ownerID: String) async throws -> ReadingList
    
    func loadList(_ listID: String) async throws -> ReadingList
    
    func updateList(_ readingList: ReadingList) async throws -> ReadingList
    
    func removeList(_ id: String) async throws -> Void
}

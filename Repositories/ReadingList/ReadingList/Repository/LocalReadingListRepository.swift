//
//  LocalReadingListRepository.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/02.
//

import Foundation

import Domain
import Extensions


public final class LocalReadingListRepository: ReadingListRepository {
    
    public func loadMyList(for ownerID: String) async throws -> ReadingList {
        throw RuntimeError("some")
    }
    
    public func loadList(_ listID: String) async throws -> ReadingList {
        throw RuntimeError("some")
    }
    
    public func updateList(_ readingList: ReadingList) async throws -> ReadingList {
        throw RuntimeError("some")
    }
    
    public func removeList(_ id: String) async throws {
        throw RuntimeError("some")
    }
}

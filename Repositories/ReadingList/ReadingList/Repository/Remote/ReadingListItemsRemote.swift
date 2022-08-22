//
//  ReadingListItemsRemote.swift
//  ReadingList
//
//  Created by sudo.park on 2022/08/19.
//

import Foundation

import Domain
import Remote
import Extensions


public protocol ReadingListItemsRemote: Sendable {
    
    func loadItems(in ids: [String]) async throws -> [ReadingListItem]
}


public final class ReadingListItemsRemoteImple: ReadingListItemsRemote {
    
    private let restRemote: RestRemote
    public init(restRemote: RestRemote) {
        self.restRemote = restRemote
    }
}

extension ReadingListItemsRemoteImple {
    
    private typealias ListsKey = ReadingListMappingKey
    private typealias LinkKey = ReadLinkItemMappingKey
    
    public func loadItems(in ids: [String]) async throws -> [ReadingListItem] {
        let listIDs = ids.filter { $0.isListID == true }
        let linkIDs = ids.filter { $0.isListID == false }
        async let lists: [ReadingListItem] = self.loadLists(in: listIDs)
        async let links: [ReadingListItem] = self.loadLinks(in: linkIDs)
        
        let itemsMap = await (lists + links).asDictionary { $0.uuid }
        return ids.compactMap { itemsMap[$0] }
    }
    
    private func loadLists(in ids: [String]) async -> [ReadingList] {
        let endpoint = ReadingListEndpoints.lists
        let query = LoadQuery().where(.init(ListsKey.uid.rawValue, .in, ids))
        return (try? await self.restRemote.requestFind(endpoint, byQuery: query)) ?? []
    }
    
    private func loadLinks(in ids: [String]) async -> [ReadLinkItem] {
        let endpoint = ReadingListEndpoints.linkItems
        let query = LoadQuery().where(.init(LinkKey.uid.rawValue, .in, ids))
        return (try? await self.restRemote.requestFind(endpoint, byQuery: query)) ?? []
    }
}

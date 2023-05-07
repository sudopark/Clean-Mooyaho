//
//  RemoteReadingListRepositoryImple.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/30.
//

import Foundation

import Domain
import Remote
import Extensions
import Prelude
import Optics
import SQLiteService


public protocol ReadingListRemote: Sendable {
    
    func loadMyList(for ownerID: String) async throws -> ReadingList
    
    func loadList(_ listID: String) async throws -> ReadingList
    
    func loadLinkItem(_ itemID: String) async throws -> ReadLinkItem
    
    func saveList(_ readingList: ReadingList,
                  at parentListID: String?) async throws -> ReadingList
    
    func updateList(_ readingList: ReadingList) async throws -> ReadingList
    
    func saveLinkItem(_ item: ReadLinkItem,
                      to listID: String?) async throws -> ReadLinkItem
    
    func updateLinkItem(_ item: ReadLinkItem) async throws -> ReadLinkItem
    
    func removeList(_ id: String) async throws
    
    func removeLinkItem(_ id: String) async throws
}


public final class ReadingListRemoteImple: ReadingListRemote, Sendable {
    
    private let restRemote: RestRemote
    public init(restRemote: RestRemote) {
        self.restRemote = restRemote
    }
}

extension ReadingListRemoteImple {
    
    private typealias ListKey = ReadingListMappingKey
    private typealias LinkKey = ReadLinkItemMappingKey
    
    public func loadMyList(for ownerID: String) async throws -> ReadingList {
        
        let listQuery = LoadQuery()
            .where(.init(ListKey.parentID.rawValue, .equal, ListKey.rootListID))
            .where(.init(ListKey.ownerID.rawValue, .equal, ownerID))
        
        let linksQuery = LoadQuery()
            .where(.init(LinkKey.parentID.rawValue, .equal, ListKey.rootListID))
            .where(.init(LinkKey.ownerID.rawValue, .equal, ownerID))
        
        return await ReadingList.makeMyRootList(ownerID)
            |> \.items .~ self.loadSubItems(listQuery, linksQuery)
            
    }
    
    public func loadList(_ listID: String) async throws -> ReadingList {
        
        let endpoint = ReadingListEndpoints.list(listID)
        let list: ReadingList = try await self.restRemote.requestFind(endpoint, byID: listID)
        
        let listQuery = LoadQuery()
            .where(.init(ListKey.parentID.rawValue, .equal, listID))
        
        let linksQuery = LoadQuery()
            .where(.init(ListKey.parentID.rawValue, .equal, listID))
        return await list
            |> \.items .~ self.loadSubItems(listQuery, linksQuery)
    }
    
    public func loadLinkItem(_ itemID: String) async throws -> ReadLinkItem {
        let endpoint = ReadingListEndpoints.linkItem(itemID)
        return try await self.restRemote.requestFind(endpoint, byID: itemID)
    }
    
    private func loadSubItems(_ listQuery: LoadQuery,
                              _ linkQuery: LoadQuery) async -> [ReadingListItem] {
        let listEndpoint = ReadingListEndpoints.lists
        let subLists: [ReadingList] = (try? await self.restRemote.requestFind(listEndpoint, byQuery: listQuery)) ?? []
        let linksEndpoint = ReadingListEndpoints.linkItems
        let subLinkItems: [ReadLinkItem] = (try? await self.restRemote.requestFind(linksEndpoint, byQuery: linkQuery)) ?? []
        return subLists + subLinkItems
    }
}

extension ReadingListRemoteImple {
    
    public func saveList(_ readingList: ReadingList,
                         at parentListID: String?) async throws -> ReadingList {
        let endpoint = ReadingListEndpoints.saveList
        let json = readingList.asJson()
            |> key(ListKey.parentID.rawValue) .~ parentListID
        return try await self.restRemote.requestSave(endpoint, json)
    }
    
    public func updateList(_ readingList: ReadingList) async throws -> ReadingList {
        let endpoint = ReadingListEndpoints.updateList(readingList.uuid)
        let json = readingList.asJson()
            |> key(ListKey.uid.rawValue) .~ nil
        return try await self.restRemote.requestUpdate(endpoint, id: readingList.uuid, to: json)
    }
    
    public func removeList(_ id: String) async throws {
        let endpoint = ReadingListEndpoints.removeList(id)
        return try await self.restRemote.requestDelete(endpoint, byId: id)
    }
    
    public func saveLinkItem(_ item: ReadLinkItem, to listID: String?) async throws -> ReadLinkItem {
        let endpoint = ReadingListEndpoints.saveLinkItem
        let json = item.asJson()
            |> key(LinkKey.parentID.rawValue) .~ listID
        return try await self.restRemote.requestSave(endpoint, json)
    }
    
    public func updateLinkItem(_ item: ReadLinkItem) async throws -> ReadLinkItem {
        let endpoint = ReadingListEndpoints.updateLinkItem(item.uuid)
        let json = item.asJson()
            |> key(LinkKey.uid.rawValue) .~ nil
        return try await self.restRemote.requestUpdate(endpoint, id: item.uuid, to: json)
    }
    
    public func removeLinkItem(_ id: String) async throws {
        let endpoint = ReadingListEndpoints.removeLinkItem(id)
        try await self.restRemote.requestDelete(endpoint, byId: id)
    }
}

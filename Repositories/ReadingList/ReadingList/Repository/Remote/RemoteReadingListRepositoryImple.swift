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


public final class RemoteReadingListRepositoryImple: ReadingListRepository {
    
    private let restRemote: RestRemote
    public init(restRemote: RestRemote) {
        self.restRemote = restRemote
    }
}

extension RemoteReadingListRepositoryImple {
    
    private typealias ListKey = ReadingListMappingKey
    private typealias LinkKey = ReadLinkItemMappingKey
    
    public func loadMyList(for ownerID: String?) async throws -> ReadingList {
        guard let ownerID = ownerID else {
            throw RuntimeError("owner id not exists")
        }
        
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
    
    private func loadSubItems(_ listQuery: LoadQuery,
                              _ linkQuery: LoadQuery) async -> [ReadingListItem] {
        let listEndpoint = ReadingListEndpoints.lists
        let subLists: [ReadingList] = (try? await self.restRemote.requestFind(listEndpoint, byQuery: listQuery)) ?? []
        let linksEndpoint = ReadingListEndpoints.linkItems
        let subLinkItems: [ReadLinkItem] = (try? await self.restRemote.requestFind(linksEndpoint, byQuery: linkQuery)) ?? []
        return subLists + subLinkItems
    }
}

extension RemoteReadingListRepositoryImple {
    
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
    
    public func removeList(_ id: String) async throws -> Void {
        let endpoint = ReadingListEndpoints.removeList(id)
        return try await self.restRemote.requestDelete(endpoint, byId: id)
    }
}

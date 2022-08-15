//
//  RemoteFavoriteReadingListItemRepositoryImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/08/15.
//

import XCTest

import Domain
import Remote
import Extensions
import Prelude
import Optics

import UnitTestHelpKit
import RemoteDoubles

@testable import ReadingList


class RemoteFavoriteReadingListItemRepositoryImpleTests: BaseTestCase {
    
    private var spyRemote: SpyRemote!
    
    override func setUpWithError() throws {
        self.spyRemote = .init()
    }
    
    override func tearDownWithError() throws {
        self.spyRemote = nil
    }
    
    private func makeRepository() -> RemoteFavoriteReadingListItemRepositoryImple {
        return .init(restRemote: self.spyRemote)
    }
}


extension RemoteFavoriteReadingListItemRepositoryImpleTests {
    
    func testRepository_loadFavoriteItemIDs() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let ids = try? await repository.loadFavoriteItemIDs(for: "some")
        
        // then
        XCTAssertEqual(ids, ["0", "1", "2"])
        XCTAssertEqual(self.spyRemote.didRequestedFindByIds, ["some"])
        let paths = self.spyRemote.didRequestedFindByIDEndpoints.map { $0.path }
        XCTAssertEqual(paths, ["reading_list/favorites"])
    }
    
    func testRepository_whenLoadFavoriteItemIDsAndOwnerIDIsNil_error() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let ids = try? await repository.loadFavoriteItemIDs(for: nil)
        
        // then
        XCTAssertNil(ids)
    }
    
    func testRepository_loadFavoriteItems() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let items = try? await repository.loadFavoriteItems(for: "some")
        
        // then
        XCTAssertEqual(items?.isNotEmpty, true)
        let paths = self.spyRemote.didRequestedFindByQueryEndpoints.map { $0.path }
        let conditions = self.spyRemote.didRequestedFindByQuerys.map { $0.matchingQuery.conditions.map { $0.stringValue } }
        XCTAssertEqual(paths, ["reading_list", "reading_list/link_items"])
        XCTAssertEqual(conditions, [
            ["uid in [\"0\", \"1\", \"2\"]"],
            ["uid in [\"0\", \"1\", \"2\"]"]
        ])
    }
    
    func testRepository_loadFavoriteItemsWithoutOwnerID_error() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let items = try? await repository.loadFavoriteItems(for: nil)
        
        // then
        XCTAssertNil(items)
    }
    
    func testRepository_toggleFavorite_toOff() async {
        // given
        let repository = self.makeRepository()
        
        // when
        try? await repository.toggleIsFavorite(for: "some", "item", isOn: false)
        
        // then
        let path = self.spyRemote.didRequestedUpdateEndpoints.map { $0.path }.first
        let toJson = self.spyRemote.didRequestedUpdateTOJsons.first
        XCTAssertEqual(path, "reading_list/favorites")
        XCTAssertEqual((toJson?[FavoriteMappingKey.ids.rawValue] as? UpdateList)?.removeItems(), ["item"])
    }
    
    func testRepository_toggleFavorite_toOn() async {
        // given
        let repository = self.makeRepository()
        
        // when
        try? await repository.toggleIsFavorite(for: "some", "item", isOn: true)
        
        // then
        let path = self.spyRemote.didRequestedUpdateEndpoints.map { $0.path }.first
        let toJson = self.spyRemote.didRequestedUpdateTOJsons.first
        XCTAssertEqual(path, "reading_list/favorites")
        XCTAssertEqual((toJson?[FavoriteMappingKey.ids.rawValue] as? UpdateList)?.insertItems(), ["item"])
    }
}


private extension RemoteFavoriteReadingListItemRepositoryImpleTests {
    
    class SpyRemote: MockRestRemote {
        
        override func requestFind<J>(_ endpoint: RestAPIEndpoint, byID: String) async throws -> J where J : JsonMappable {
            let _: J? = try? await super.requestFind(endpoint, byID: byID)
            
            return MemberFavoriteListItem(ownerID: "some", ids: ["0", "1", "2"]) as! J
        }
        
        override func requestFind<J>(_ endpoint: RestAPIEndpoint, byQuery: LoadQuery) async throws -> [J] where J : JsonMappable {
            
            let _: [J]? = try? await super.requestFind(endpoint, byQuery: byQuery)
            
            switch J.self {
            case is ReadingList.Type: return [ReadingList(uuid: "list", name: "list") as! J]
            case is ReadLinkItem.Type: return [ReadLinkItem(uuid: "link", link: "link") as! J]
            default: throw RuntimeError("failed")
            }
        }
        
        override func requestUpdate<J>(_ endpoint: RestAPIEndpoint, id: String, to: [String : Any]) async throws -> J where J : JsonMappable {
            let _: J? = try? await super.requestUpdate(endpoint, id: id, to: to)
            return MemberFavoriteListItem(ownerID: "some", ids: ["0", "1", "2"]) as! J
        }
    }
}


extension UpdateList {
    
    func removeItems<T>() -> [T]? {
        guard case let .remove(elements) = self else { return nil }
        return elements.compactMap { $0 as? T }
    }
    
    func insertItems<T>() -> [T]? {
        guard case let .union(elements) = self else { return nil }
        return elements.compactMap { $0 as? T }
    }
}

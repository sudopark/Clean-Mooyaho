//
//  FavoriteReadingListItemRemoteImpleTests.swift
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


class FavoriteReadingListItemRemoteImpleTests: BaseTestCase {
    
    private var spyRestRemote: SpyRestRemote!
    
    override func setUpWithError() throws {
        self.spyRestRemote = .init()
    }
    
    override func tearDownWithError() throws {
        self.spyRestRemote = nil
    }
    
    private func makeRemote(withSignIn: Bool = true) -> FavoriteReadingListItemRemoteImple {
        let auth = withSignIn ? Auth(userID: "some") : nil
        return .init(restRemote: self.spyRestRemote)
    }
}


extension FavoriteReadingListItemRemoteImpleTests {
    
    func testRemote_loadFavoriteItemIDs() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let ids = try? await remote.loadFavoriteItemIDs(for: "some")
        
        // then
        XCTAssertEqual(ids, ["0", "1", "2"])
        XCTAssertEqual(self.spyRestRemote.didRequestedFindByIds, ["some"])
        let paths = self.spyRestRemote.didRequestedFindByIDEndpoints.map { $0.path }
        XCTAssertEqual(paths, ["reading_list/favorites"])
    }
    
    func testRemote_toggleFavorite_toOff() async {
        // given
        let remote = self.makeRemote()
        
        // when
        try? await remote.toggleIsFavorite(for: "owner", "item", isOn: false)
        
        // then
        let path = self.spyRestRemote.didRequestedUpdateEndpoints.map { $0.path }.first
        let toJson = self.spyRestRemote.didRequestedUpdateTOJsons.first
        XCTAssertEqual(path, "reading_list/favorites")
        XCTAssertEqual((toJson?[FavoriteMappingKey.ids.rawValue] as? UpdateList)?.removeItems(), ["item"])
    }
    
    func testRemote_toggleFavorite_toOn() async {
        // given
        let remote = self.makeRemote()
        
        // when
        try? await remote.toggleIsFavorite(for: "owner", "item", isOn: true)
        
        // then
        let path = self.spyRestRemote.didRequestedUpdateEndpoints.map { $0.path }.first
        let toJson = self.spyRestRemote.didRequestedUpdateTOJsons.first
        XCTAssertEqual(path, "reading_list/favorites")
        XCTAssertEqual((toJson?[FavoriteMappingKey.ids.rawValue] as? UpdateList)?.insertItems(), ["item"])
    }
}


private extension FavoriteReadingListItemRemoteImpleTests {
    
    class SpyRestRemote: MockRestRemote {
        
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

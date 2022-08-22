//
//  ReadingListRemoteImpleTests.swift
//  ReadingListTests
//
//  Created by sudo.park on 2022/07/30.
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


class ReadingListRemoteImpleTests: BaseTestCase {
    
    private var stubRestRemote: StubRemote!
    
    override func tearDownWithError() throws {
        self.stubRestRemote = nil
    }
    
    private func makeRemote(
        shouldFaildLoadMyList: Bool = false,
        shouldFailLoadListById: Bool = false,
        shouldFailSaveList: Bool = false,
        shouldFailUpdateList: Bool = false,
        shouldFailRemoveList: Bool = false
    ) -> ReadingListRemoteImple {
        
        let remote = StubRemote()
        remote.shouldFailLoadSubLists = shouldFaildLoadMyList
        remote.shouldFailFindSubListById = shouldFailLoadListById
        remote.shouldFailSaveList = shouldFailSaveList
        remote.shouldFailUpdateList = shouldFailUpdateList
        remote.shouldFailDeleteList = shouldFailRemoveList
        self.stubRestRemote = remote
        return ReadingListRemoteImple(restRemote: remote)
    }
}


// MARK: - load my list

extension ReadingListRemoteImpleTests {
    
    // 내 목록 로드
    func testRemote_loadMyList() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let list = try? await remote.loadMyList(for: "some")
        
        // then
        XCTAssertNotNil(list)
    }

    // 내 목록 로드 요청시에 쿼리 검증
    func testRemote_whenLoadMyList_loadSubListsAndItems() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let _ = try? await remote.loadMyList(for: "owner_id")
        
        // then
        let endpoints = self.stubRestRemote.didRequestedFindByQueryEndpoints
        let queries = self.stubRestRemote.didRequestedQueries
        XCTAssertEqual(endpoints.map { $0.path }, ["reading_list", "reading_list/link_items"])
        XCTAssertEqual(endpoints.map { $0.method }, [.get, .get])
        XCTAssertEqual(queries.map { $0.matchingQuery.conditions.map { $0.stringValue } }, [
            ["pid = root", "oid = owner_id"],
            ["pid = root", "oid = owner_id"]
        ])
    }
    
    // 내목록 - 서브목록 로드 실패해도 무시
    func testRemote_failToLoadMyListsSubList_ignoreError() async {
        // given
        let remote = self.makeRemote(shouldFaildLoadMyList: true)
        
        // when
        let list = try? await remote.loadMyList(for: "owner_id")
        
        // then
        XCTAssertEqual(list?.items.compactMap{ $0 as? ReadingList }.isEmpty, true)
    }
}


// MARK: - load list

extension ReadingListRemoteImpleTests {
    
    // 내 목록 로드
    func testRemote_loadList() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let list = try? await remote.loadList("some")
        
        // then
        XCTAssertNotNil(list)
    }

    // 내 목록 로드 요청시에 쿼리 검증
    func testRemote_whenLoadList_loadSubListsAndItems() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let _ = try? await remote.loadList("some")
        
        // then
        let endpoints = self.stubRestRemote.didRequestedFindByIdEndpoints
        XCTAssertEqual(endpoints.map { $0.path }, ["reading_list/some"])
        XCTAssertEqual(endpoints.map { $0.method }, [.get])
        XCTAssertEqual(self.stubRestRemote.didRequestedFindByID, "some")
        
        let subEndpoints = self.stubRestRemote.didRequestedFindByQueryEndpoints
        let subQueries = self.stubRestRemote.didRequestedQueries
        XCTAssertEqual(subEndpoints.map { $0.path }, ["reading_list", "reading_list/link_items"])
        XCTAssertEqual(subEndpoints.map { $0.method }, [.get, .get])
        XCTAssertEqual(subQueries.map { $0.matchingQuery.conditions.map { $0.stringValue } }, [
            ["pid = some"], ["pid = some"]
        ])
    }
    
    // 내목록 - 서브목록 로드 실패해도 무시
    func testRemote_failToLoadSubList_ignoreError() async {
        // given
        let remote = self.makeRemote(shouldFaildLoadMyList: true)
        
        // when
        let list = try? await remote.loadList("some")
        
        // then
        XCTAssertEqual(list?.items.compactMap{ $0 as? ReadingList }.isEmpty, true)
    }
    
    func testRemote_whenLoadListFail_throwError() async {
        // given
        let remote = self.makeRemote(shouldFailLoadListById: true)
        
        // when + then
        do {
            let _ = try await remote.loadList("some")
            XCTFail("should throw error")
        } catch {
            XCTAssert(true)
        }
    }
}


// MARK: - load link item

extension ReadingListRemoteImpleTests {
    
    func testRemote_loadLinkItem() async {
        // given
        let remote = self.makeRemote()
        
        // when
        let link = try? await remote.loadLinkItem("some")
        
        // then
        XCTAssertNotNil(link)
        XCTAssertEqual(self.stubRestRemote.didRequestedFindByID, "some")
        XCTAssertEqual(self.stubRestRemote.didRequestedFindByIdEndpoints.map { $0.path },[
            "reading_list/link_item/some"
        ])
        XCTAssertEqual(self.stubRestRemote.didRequestedFindByIdEndpoints.map { $0.method },[
            .get
        ])
    }
}


// MARK: - save + update List

extension ReadingListRemoteImpleTests {
    
    private var dummyList: ReadingList {
        return ReadingList.makeList("some", ownerID: "owner")
            |> \.createdAt .~ 100
            |> \.lastUpdatedAt .~ 200
            |> \.description .~ "desc"
            |> \.categoryIds .~ ["c1", "c2"]
            |> \.priorityID .~ 1
    }
    
    func testRemote_saveListAtMyList() async {
        // given
        let remote = self.makeRemote()
        let list = self.dummyList
        
        // when
        let newList = try? await remote.saveList(list, at: nil)
        
        // then
        XCTAssertNotNil(newList)
        XCTAssertEqual(self.stubRestRemote.didRequestedSaveEndpoint?.path, "reading_list")
        XCTAssertEqual(self.stubRestRemote.didRequestedSaveEndpoint?.method, .post)
        
        let entities = self.stubRestRemote.didRequestedSaveEntities ?? [:]
        XCTAssertEqual(entities["uid"] as? String, list.uuid)
        XCTAssertEqual(entities["oid"] as? String, "owner")
        XCTAssertEqual(entities["pid"] as? String, nil)
        XCTAssertEqual(entities["crt_at"] as? TimeInterval, 100)
        XCTAssertEqual(entities["lst_up_at"] as? TimeInterval, 200)
        XCTAssertEqual(entities["priority"] as? Int, 1)
        XCTAssertEqual(entities["cate_ids"] as? [String], ["c1", "c2"])
        XCTAssertEqual(entities["nm"] as? String, "some")
        XCTAssertEqual(entities["cllc_desc"] as? String, "desc")
    }
    
    func testRemote_saveListAtSomeList() async {
        // given
        let remote = self.makeRemote()
        let list = ReadingList.makeList("some", ownerID: "owner")
        
        // when
        let newList = try? await remote.saveList(list, at: "parent_list")
        
        // then
        XCTAssertNotNil(newList)
        XCTAssertEqual(self.stubRestRemote.didRequestedSaveEntities?["pid"] as? String, "parent_list")
    }
    
    func testRemote_saveListFail() async {
        // given
        let remote = self.makeRemote(shouldFailSaveList: true)
        let list = ReadingList.makeList("some", ownerID: "owner")
        
        // when
        let newList = try? await remote.saveList(list, at: nil)
        
        // then
        XCTAssertNil(newList)
    }
    
    func testRemote_updateList() async {
        // given
        let remote = self.makeRemote()
        let oldList = self.dummyList
        let newList = oldList |> \.name .~ "new name"
        
        // when
        let updatedList = try? await remote.updateList(newList)
        
        // then
        XCTAssertNotNil(updatedList)
        XCTAssertNotNil(self.stubRestRemote.didUpdatedProperties)
        XCTAssertEqual(self.stubRestRemote.didUpdatedProperties?["uid"] as? String, nil)
    }
    
    func testRemote_updateListFail() async {
        // given
        let remote = self.makeRemote(shouldFailUpdateList: true)
        let newList = self.dummyList |> \.name .~ "new name"
        
        // when
        let updatedList = try? await remote.updateList(newList)
        
        // then
        XCTAssertNil(updatedList)
    }
}


// MARK: - save and update link item

extension ReadingListRemoteImpleTests {
    
    private var dummyLink: ReadLinkItem {
        return ReadLinkItem.make("some")
            |> \.ownerID .~ "owner"
            |> \.createdAt .~ 100
            |> \.lastUpdatedAt .~ 200
            |> \.categoryIds .~ ["c1", "c2"]
            |> \.priorityID .~ 1
            |> \.customName .~ "custom"
            |> \.isRead .~ true
    }
    
    func testRemote_saveLinkItemAtMyList() async {
        // given
        let remote = self.makeRemote()
        let link = self.dummyLink
        
        // when
        let newLink = try? await remote.saveLinkItem(link, to: nil)
        
        // then
        XCTAssertNotNil(newLink)
        XCTAssertEqual(self.stubRestRemote.didRequestedSaveEndpoint?.path, "reading_list/link_items")
        XCTAssertEqual(self.stubRestRemote.didRequestedSaveEndpoint?.method, .post)
        
        let entities = self.stubRestRemote.didRequestedSaveEntities ?? [:]
        XCTAssertEqual(entities["uid"] as? String, link.uuid)
        XCTAssertEqual(entities["oid"] as? String, "owner")
        XCTAssertEqual(entities["pid"] as? String, nil)
        XCTAssertEqual(entities["crt_at"] as? TimeInterval, 100)
        XCTAssertEqual(entities["lst_up_at"] as? TimeInterval, 200)
        XCTAssertEqual(entities["priority"] as? Int, 1)
        XCTAssertEqual(entities["cate_ids"] as? [String], ["c1", "c2"])
        XCTAssertEqual(entities["custom_nm"] as? String, "custom")
        XCTAssertEqual(entities["is_red"] as? Bool, true)
    }
    
    func testRemote_saveLinkAtSomeList() async {
        // given
        let remote = self.makeRemote()
        let link = self.dummyLink
        
        // when
        let newLink = try? await remote.saveLinkItem(link, to: "parent_list")
        
        // then
        XCTAssertNotNil(newLink)
        XCTAssertEqual(self.stubRestRemote.didRequestedSaveEntities?["pid"] as? String, "parent_list")
    }
    
    func testRemote_updateLinkItem() async {
        // given
        let remote = self.makeRemote()
        let oldLink = self.dummyLink
        let newLink = oldLink |> \.customName .~ "new name"
        
        // when
        let updatedLink = try? await remote.updateLinkItem(newLink)
        
        // then
        XCTAssertNotNil(updatedLink)
        XCTAssertNotNil(self.stubRestRemote.didUpdatedProperties)
        XCTAssertEqual(self.stubRestRemote.didUpdatedProperties?["uid"] as? String, nil)
    }
}


// MARK: remove list + link item

extension ReadingListRemoteImpleTests {
    
    func testRemote_removeList() async {
        // given
        let remote = self.makeRemote()
        
        // when + then
        do {
            try await remote.removeList("some")
            XCTAssert(true)
        } catch {
            XCTFail("should not throw error")
        }
        XCTAssertEqual(self.stubRestRemote.didDeleteRequestedEndpoint?.path, "reading_list/some")
        XCTAssertEqual(self.stubRestRemote.didDeleteRequestedEndpoint?.method, .delete)
    }
    
    func testRemote_removeLinkItem() async {
        // given
        let remote = self.makeRemote()
        
        // when + then
        do {
            try await remote.removeLinkItem("some")
            XCTAssert(true)
        } catch {
            XCTFail("should not throw error")
        }
        XCTAssertEqual(self.stubRestRemote.didDeleteRequestedEndpoint?.path, "reading_list/link_item/some")
        XCTAssertEqual(self.stubRestRemote.didDeleteRequestedEndpoint?.method, .delete)
    }
    
    func testRemote_failToRemoveList() async {
        // given
        let remote = self.makeRemote(shouldFailRemoveList: true)
        
        // when + then
        do {
            try await remote.removeList("some")
            XCTFail("should throw error")
        } catch {
            XCTAssert(true)
        }
    }
}


private extension ReadingListRemoteImpleTests {
    
    class StubRemote: MockRestRemote {
        
        var shouldFailFindSubListById: Bool = false
        var didRequestedFindByID: String?
        var didRequestedFindByIdEndpoints: [RestAPIEndpoint] = []
        override func requestFind<J>(_ endpoint: RestAPIEndpoint, byID: String) async throws -> J where J : JsonMappable {
            self.didRequestedFindByID = byID
            self.didRequestedFindByIdEndpoints.append(endpoint)
            
            switch J.self {
            case is ReadingList.Type where self.shouldFailFindSubListById == true:
                throw RuntimeError("failed")
                
            case is ReadingList.Type:
                return ReadingList.makeList("sub", ownerID: "owner") as! J
                
            case is ReadLinkItem.Type:
                return ReadLinkItem.make("sub") as! J
                
            default: throw RuntimeError("failed")
            }
        }
        
        var shouldFailLoadSubLists: Bool = false
        var didRequestedQueries: [LoadQuery] = []
        override func requestFind<J>(_ endpoint: RestAPIEndpoint, byQuery: LoadQuery) async throws -> [J] where J : JsonMappable {
            self.didRequestedFindByQueryEndpoints.append(endpoint)
            self.didRequestedQueries.append(byQuery)
            switch J.self {
            case is ReadingList.Type where self.shouldFailLoadSubLists == true:
                throw RuntimeError("failed")
                
            case is ReadingList.Type:
                return [ReadingList.makeList("some", ownerID: "owner")] as! [J]
                
            case is ReadLinkItem.Type:
                return [ReadLinkItem.make("some")] as! [J]
                
            default: throw RuntimeError("failed")
            }
        }
        
        var shouldFailSaveList: Bool = false
        var didRequestedSaveEndpoint: RestAPIEndpoint?
        var didRequestedSaveEntities: [String: Any]?
        override func requestSave<J>(_ endpoint: RestAPIEndpoint, _ entities: [String : Any]) async throws -> J where J : JsonMappable {
            self.didRequestedSaveEndpoint = endpoint
            self.didRequestedSaveEntities = entities
            
            switch J.self {
            case is ReadingList.Type where self.shouldFailSaveList == true:
                throw RuntimeError("failed")
                
            case is ReadingList.Type:
                return ReadingList.makeList("new", ownerID: "owner") as! J
                
            case is ReadLinkItem.Type:
                return ReadLinkItem.make("some") as! J
                
            default: throw RuntimeError("failed")
            }
        }
        
        var shouldFailUpdateList: Bool = false
        var didRequestedUpdateEndpoint: RestAPIEndpoint?
        var didUpdatedProperties: [String: Any]?
        override func requestUpdate<J>(_ endpoint: RestAPIEndpoint, id: String, to: [String : Any]) async throws -> J where J : JsonMappable {
            self.didUpdatedProperties = to
            self.didRequestedUpdateEndpoint = endpoint
            
            switch J.self {
            case is ReadingList.Type where self.shouldFailUpdateList == true:
                throw RuntimeError("failed")
                
            case is ReadingList.Type:
                return ReadingList.makeList("updated", ownerID: "owner") as! J
                
            case is ReadLinkItem.Type:
                return ReadLinkItem.make("updated") as! J
                
            default: throw RuntimeError("failed")
            }
        }
        
        var shouldFailDeleteList: Bool = false
        var didDeleteRequestedEndpoint: RestAPIEndpoint?
        override func requestDelete(_ endpoint: RestAPIEndpoint, byId: String) async throws {
            self.didDeleteRequestedEndpoint = endpoint
            guard shouldFailDeleteList else { return }
            throw RuntimeError("failed")
        }
    }
}

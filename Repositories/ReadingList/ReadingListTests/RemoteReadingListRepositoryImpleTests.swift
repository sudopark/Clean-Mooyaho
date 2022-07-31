//
//  RemoteReadingListRepositoryImpleTests.swift
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


class RemoteReadingListRepositoryImpleTests: BaseTestCase {
    
    private var stubRemote: StubRemote!
    
    override func tearDownWithError() throws {
        self.stubRemote = nil
    }
    
    private func makeRepository(
        shouldFaildLoadMyList: Bool = false,
        shouldFailLoadListById: Bool = false,
        shouldFailSaveList: Bool = false,
        shouldFailUpdateList: Bool = false,
        shouldFailRemoveList: Bool = false
    ) -> RemoteReadingListRepositoryImple {
        
        let remote = StubRemote()
        remote.shouldFailLoadSubLists = shouldFaildLoadMyList
        remote.shouldFailFindSubListById = shouldFailLoadListById
        remote.shouldFailSaveList = shouldFailSaveList
        remote.shouldFailUpdateList = shouldFailUpdateList
        remote.shouldFailDeleteList = shouldFailRemoveList
        self.stubRemote = remote
        return RemoteReadingListRepositoryImple(restRemote: remote)
    }
}


// MARK: - load my list

extension RemoteReadingListRepositoryImpleTests {
    
    // 내 목록 로드시에 ownerID 없으면 에러
    func testRepository_whenLoadMyListWithoutOwnerID_error() async {
        // given
        let repository = self.makeRepository()
        
        // when + then
        do {
            let _ = try await repository.loadMyList(for: nil)
            XCTFail("should throw error")
        } catch {
            XCTAssert(true)
        }
    }
    
    // 내 목록 로드
    func testRepository_loadMyList() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let list = try? await repository.loadMyList(for: "some")
        
        // then
        XCTAssertNotNil(list)
    }

    // 내 목록 로드 요청시에 쿼리 검증
    func testRepository_whenLoadMyList_loadSubListsAndItems() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let _ = try? await repository.loadMyList(for: "owner_id")
        
        // then
        let endpoints = self.stubRemote.didRequestedFindByQueryEndpoints
        let queries = self.stubRemote.didRequestedQueries
        XCTAssertEqual(endpoints.map { $0.path }, ["reading_list", "reading_list/link_items"])
        XCTAssertEqual(endpoints.map { $0.method }, [.get, .get])
        XCTAssertEqual(queries.map { $0.matchingQuery.conditions.map { $0.stringValue } }, [
            ["pid = root", "oid = owner_id"],
            ["pid = root", "oid = owner_id"]
        ])
    }
    
    // 내목록 - 서브목록 로드 실패해도 무시
    func testRepository_failToLoadMyListsSubList_ignoreError() async {
        // given
        let repository = self.makeRepository(shouldFaildLoadMyList: true)
        
        // when
        let list = try? await repository.loadMyList(for: "owner_id")
        
        // then
        XCTAssertEqual(list?.items.compactMap{ $0 as? ReadingList }.isEmpty, true)
    }
}


// MARK: - load list

extension RemoteReadingListRepositoryImpleTests {
    
    // 내 목록 로드
    func testRepository_loadList() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let list = try? await repository.loadList("some")
        
        // then
        XCTAssertNotNil(list)
    }

    // 내 목록 로드 요청시에 쿼리 검증
    func testRepository_whenLoadList_loadSubListsAndItems() async {
        // given
        let repository = self.makeRepository()
        
        // when
        let _ = try? await repository.loadList("some")
        
        // then
        let endpoints = self.stubRemote.didRequestedFindByIdEndpoints
        XCTAssertEqual(endpoints.map { $0.path }, ["reading_list/some"])
        XCTAssertEqual(endpoints.map { $0.method }, [.get])
        XCTAssertEqual(self.stubRemote.didRequestedFindByID, "some")
        
        let subEndpoints = self.stubRemote.didRequestedFindByQueryEndpoints
        let subQueries = self.stubRemote.didRequestedQueries
        XCTAssertEqual(subEndpoints.map { $0.path }, ["reading_list", "reading_list/link_items"])
        XCTAssertEqual(subEndpoints.map { $0.method }, [.get, .get])
        XCTAssertEqual(subQueries.map { $0.matchingQuery.conditions.map { $0.stringValue } }, [
            ["pid = some"], ["pid = some"]
        ])
    }
    
    // 내목록 - 서브목록 로드 실패해도 무시
    func testRepository_failToLoadSubList_ignoreError() async {
        // given
        let repository = self.makeRepository(shouldFaildLoadMyList: true)
        
        // when
        let list = try? await repository.loadList("some")
        
        // then
        XCTAssertEqual(list?.items.compactMap{ $0 as? ReadingList }.isEmpty, true)
    }
    
    func testRepository_whenLoadListFail_throwError() async {
        // given
        let repository = self.makeRepository(shouldFailLoadListById: true)
        
        // when + then
        do {
            let _ = try await repository.loadList("some")
            XCTFail("should throw error")
        } catch {
            XCTAssert(true)
        }
    }
}


// MARK: - save + update List

extension RemoteReadingListRepositoryImpleTests {
    
    private var dummyList: ReadingList {
        return ReadingList.makeList("some", ownerID: "owner")
            |> \.createdAt .~ 100
            |> \.lastUpdatedAt .~ 200
            |> \.description .~ "desc"
            |> \.categoryIds .~ ["c1", "c2"]
            |> \.priorityID .~ 1
    }
    
    func testRepository_saveListAtMyList() async {
        // given
        let repository = self.makeRepository()
        let list = self.dummyList
        
        // when
        let newList = try? await repository.saveList(list, at: nil)
        
        // then
        XCTAssertNotNil(newList)
        XCTAssertEqual(self.stubRemote.didRequestedSaveEndpoint?.path, "reading_list")
        XCTAssertEqual(self.stubRemote.didRequestedSaveEndpoint?.method, .post)
        
        let entities = self.stubRemote.didRequestedSaveEntities ?? [:]
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
    
    func testRepository_saveListAtSomeList() async {
        // given
        let repository = self.makeRepository()
        let list = ReadingList.makeList("some", ownerID: "owner")
        
        // when
        let newList = try? await repository.saveList(list, at: "parent_list")
        
        // then
        XCTAssertNotNil(newList)
        XCTAssertEqual(self.stubRemote.didRequestedSaveEntities?["pid"] as? String, "parent_list")
    }
    
    func testRepository_saveListFail() async {
        // given
        let repository = self.makeRepository(shouldFailSaveList: true)
        let list = ReadingList.makeList("some", ownerID: "owner")
        
        // when
        let newList = try? await repository.saveList(list, at: nil)
        
        // then
        XCTAssertNil(newList)
    }
    
    func testRepository_updateList() async {
        // given
        let repository = self.makeRepository()
        let oldList = self.dummyList
        let newList = oldList |> \.name .~ "new name"
        
        // when
        let updatedList = try? await repository.updateList(newList)
        
        // then
        XCTAssertNotNil(updatedList)
        XCTAssertNotNil(self.stubRemote.didUpdatedProperties)
        XCTAssertEqual(self.stubRemote.didUpdatedProperties?["uid"] as? String, nil)
    }
    
    func testRepository_updateListFail() async {
        // given
        let repository = self.makeRepository(shouldFailUpdateList: true)
        let newList = self.dummyList |> \.name .~ "new name"
        
        // when
        let updatedList = try? await repository.updateList(newList)
        
        // then
        XCTAssertNil(updatedList)
    }
}


// MARK: remove list

extension RemoteReadingListRepositoryImpleTests {
    
    func testRepository_removeList() async {
        // given
        let repository = self.makeRepository()
        
        // when + then
        do {
            try await repository.removeList("some")
            XCTAssert(true)
        } catch {
            XCTFail("should not throw error")
        }
        XCTAssertEqual(self.stubRemote.didDeleteRequestedEndpoint?.path, "reading_list/some")
        XCTAssertEqual(self.stubRemote.didDeleteRequestedEndpoint?.method, .delete)
    }
    
    func testRepository_failToRemoveList() async {
        // given
        let repository = self.makeRepository(shouldFailRemoveList: true)
        
        // when + then
        do {
            try await repository.removeList("some")
            XCTFail("should throw error")
        } catch {
            XCTAssert(true)
        }
    }
}


private extension RemoteReadingListRepositoryImpleTests {
    
    class StubRemote: MockRestRemote {
        
        var shouldFailFindSubListById: Bool = false
        var didRequestedFindByID: String?
        var didRequestedFindByIdEndpoints: [RestAPIEndpoint] = []
        override func requestFind<J>(_ endpoint: RestAPIEndpoint, byID: String) async throws -> J where J : JsonMappable {
            self.didRequestedFindByID = byID
            self.didRequestedFindByIdEndpoints.append(endpoint)
            guard shouldFailFindSubListById == false
            else {
                throw RuntimeError("failed")
            }
            return ReadingList.makeList("sub", ownerID: "owner") as! J
        }
        
        var shouldFailLoadSubLists: Bool = false
        var didRequestedFindByQueryEndpoints: [RestAPIEndpoint] = []
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
                return []
                
            default: throw RuntimeError("failed")
            }
        }
        
        var shouldFailSaveList: Bool = false
        var didRequestedSaveEndpoint: RestAPIEndpoint?
        var didRequestedSaveEntities: [String: Any]?
        override func requestSave<J>(_ endpoint: RestAPIEndpoint, _ entities: [String : Any]) async throws -> J where J : JsonMappable {
            self.didRequestedSaveEndpoint = endpoint
            self.didRequestedSaveEntities = entities
            guard self.shouldFailSaveList == false
            else {
                throw RuntimeError("failed")
            }
            return ReadingList.makeList("new", ownerID: "owner") as! J
        }
        
        var shouldFailUpdateList: Bool = false
        var didRequestedUpdateEndpoint: RestAPIEndpoint?
        var didUpdatedProperties: [String: Any]?
        override func requestUpdate<J>(_ endpoint: RestAPIEndpoint, id: String, to: [String : Any]) async throws -> J where J : JsonMappable {
            self.didUpdatedProperties = to
            self.didRequestedUpdateEndpoint = endpoint
            guard self.shouldFailUpdateList == false
            else {
                throw RuntimeError("failed")
            }
            return ReadingList.makeList("updated", ownerID: "owner") as! J
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

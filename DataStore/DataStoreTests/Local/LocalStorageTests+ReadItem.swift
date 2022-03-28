//
//  LocalStorageTests+ReadItem.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ReadItem: BaseLocalStorageTests {
    
    private var dummyCategories: [ItemCategory] {
        return (0..<3).map{ .init(uid: "c:\($0)", name: "n:\($0)", colorCode: "$0", createdAt: .now()) }
    }
    
    private func collection(at int: Int, parent: String? = nil) -> ReadCollection {
        return ReadCollection(uid: "c:\(int)", name: "collection:\(int)", createdAt: .now(), lastUpdated: .now())
            |> \.parentID .~ parent
            |> \.categoryIDs .~ self.dummyCategories.map { $0.uid }
    }
    
    private func link(at int: Int, parent: String? = nil) -> ReadLink {
        return ReadLink(uid: "l:\(int)", link: "link:\(int)", createAt: .now(), lastUpdated: .now())
            |> \.parentID .~ parent
            |> \.categoryIDs .~ self.dummyCategories.map { $0.uid }
    }
    
    private func dummyMyItems() -> [ReadItem] {
        
        let (c1,        c2,  l1) = (self.collection(at: 1), self.collection(at: 2), self.link(at: 1))
        let (c11, l11,  l22) = (self.collection(at: 11, parent: c1.uid), self.link(at: 11, parent: c1.uid),
                                self.link(at: 22, parent: c2.uid))
        let l111 = self.link(at: 111, parent: c11.uid)
        return [c1, c11, l111, l11, c2, l22, l1]
    }
}


extension LocalStorageTests_ReadItem {
    
    // load my item -> c1, c2, l1
    func testStorage_loadMyItems() {
        // given
        let expect = expectation(description: "내 아이템(최상위 아이템) 로드")
        let saveAllItems = self.local.updateReadItems(self.dummyMyItems())
        
        // when
        let loadMyItems = self.local.fetchMyItems(memberID: nil)
        let saveAndLoad = saveAllItems.flatMap{ _ in loadMyItems }
        let items = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let myItemIDs = items?.map{ $0.uid }
        XCTAssertEqual(myItemIDs, [
            self.collection(at: 1).uid, self.collection(at: 2).uid, self.link(at: 1).uid
        ])
    }
    
    // load c1 items -> c11, l11
    func testStorage_loadCollectionItems() {
        // given
        let expect = expectation(description: "collection의 item 로드")
        let saveAllItems = self.local.updateReadItems(self.dummyMyItems())
        
        // when
        let collection1 = self.collection(at: 1)
        let loadCollection1items = self.local.fetchCollectionItems(collection1.uid)
        let saveAndLoad = saveAllItems.flatMap{ _ in loadCollection1items }
        let items = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let itemIDs = items?.map{ $0.uid }
        XCTAssertEqual(itemIDs, [
            self.collection(at: 11).uid, self.link(at: 11).uid
        ])
    }
    
    // add node c22 -> load c2 items -> c22, l22
    func testStorage_addC22AtC2_andLoadC2Items() {
        // given
        let expect = expectation(description: "c2 하위에 c22 추가하고 c2 item 로드")
        let saveAllItems = self.local.updateReadItems(self.dummyMyItems())
        
        // when
        let collection2 = self.collection(at: 2)
        let collection22 = self.collection(at: 22) |> \.parentID .~ collection2.uid
        let saveCollection22 = self.local.updateReadItems([collection22])
        let loadCollection2items = self.local.fetchCollectionItems(collection2.uid)
        let saveAndLoad = saveAllItems.flatMap{ _ in saveCollection22 }.flatMap { loadCollection2items }
        let items = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        let itemIDs = items?.map{ $0.uid }
        XCTAssertEqual(itemIDs, [
            self.collection(at: 22).uid, self.link(at: 22).uid
        ])
    }
    
    // save l2 at root -> load and verify fields
    func testStorage_saveNewLink_andVerifyAllFields() {
        // given
        let expect = expectation(description: "link item 저장 이후 필드 검사")
        
        let link = ReadLink(uid: "uid", link: "link://www", createAt: 100, lastUpdated: 100)
            |> \.ownerID .~ "owner"
            |> \.customName .~ "custom name"
            |> \.priority .~ .afterAWhile
            |> \.categoryIDs .~ ["c1"]
            |> \.isRed .~ true
        
        // when
        let save = self.local.updateReadItems([link])
        let load = self.local.fetchMyItems(memberID: nil)
        let saveAndLoad = save.flatMap{ _ in load }
        let savedLink = self.waitFirstElement(expect, for: saveAndLoad.asObservable())?.first as? ReadLink
        
        // then
        XCTAssertEqual(savedLink?.uid, link.uid)
        XCTAssertEqual(savedLink?.ownerID, link.ownerID)
        XCTAssertEqual(savedLink?.parentID, link.parentID)
        XCTAssertEqual(savedLink?.link, link.link)
        XCTAssertEqual(savedLink?.createdAt, link.createdAt)
        XCTAssertEqual(savedLink?.lastUpdatedAt, link.lastUpdatedAt)
        XCTAssertEqual(savedLink?.customName, link.customName)
        XCTAssertEqual(savedLink?.priority, link.priority)
        XCTAssertEqual(savedLink?.categoryIDs.count, link.categoryIDs.count)
        XCTAssertEqual(savedLink?.isRed, true)
    }
    
    func testStorage_loadCollection() {
        // given
        let expect = expectation(description: "저장된 특정 콜렉션 로드")
        
        let dummyCollection = ReadCollection(name: "some")
        
        // when
        let save = self.local.updateReadItems([dummyCollection])
        let load = self.local.fetchCollection(dummyCollection.uid)
        let saveAndLoad = save.flatMap{ _ in load }
        let collection = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertNotNil(collection)
    }
    
    func testStorage_loadReadLink() {
        // given
        let expect = expectation(description: "저장된 특정 read link 로드")
        
        let dummy = ReadLink(link: "some")
        
        // when
        let save = self.local.updateReadItems([dummy])
        let load = self.local.fetchReadLink(dummy.uid)
        let saveAndLoad = save.flatMap{ _ in load }
        let link = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertNotNil(link)
    }
    
    func testStorage_updateCollection_withParams() {
        // given
        let expect = expectation(description: "파라미터로 콜렉션 업데이트")
        let dummy = ReadCollection(name: "some")
        let params = ReadItemUpdateParams(item: ReadCollection(name: "some"))
        let newTime: TimeStamp = 100_000_000
        
        // when
        let save = self.local.updateReadItems([dummy])
        let updateParams = params |> \.updatePropertyParams .~ [.remindTime(newTime)]
        let update = self.local.updateItem(updateParams)
        let load = self.local.fetchCollection(dummy.uid)
        let saveUpdateAndLoad = save.flatMap { update }.flatMap { load }
        let loadedCollection = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedCollection?.remindTime, newTime)
    }
    
    func testStorage_removeCollectionProperty_withParams() {
        // given
        let expect = expectation(description: "파라미터로 콜렉션 프로퍼티 삭제 업데이트")
        let dummy = ReadCollection(name: "some") |> \.remindTime .~ (.now() + 1000)
        let params = ReadItemUpdateParams(item: dummy)
        
        // when
        let save = self.local.updateReadItems([dummy])
        let removeParams = params |> \.updatePropertyParams .~ [.remindTime(nil)]
        let remove = self.local.updateItem(removeParams)
        let load = self.local.fetchCollection(dummy.uid)
        let saveRemoveAndLoad = save.flatMap { remove }.flatMap { load }
        let loadedCollection = self.waitFirstElement(expect, for: saveRemoveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(loadedCollection?.remindTime, nil)
    }
    
    func testStorage_updateLink_withParams() {
        // given
        let expect = expectation(description: "파라미터로 link 업데이트")
        let dummy = ReadLink(link: "some")
            |> \.parentID .~ "p"
            |> \.isRed .~ false
        let params = ReadItemUpdateParams(item: dummy)
        let newTime: TimeStamp = 200
        
        // when
        let save = self.local.updateReadItems([dummy])
        let updateParams = params
            |> \.updatePropertyParams .~ [.remindTime(newTime), .isRed(true)]
        let update = self.local.updateItem(updateParams)
        let load = self.local.fetchCollectionItems("p")
        let saveUpdateAndLoad = save.flatMap { update }.flatMap { load }
        let loadedLink = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())?.first
        
        // then
        XCTAssertEqual(loadedLink?.remindTime, newTime)
        XCTAssertEqual((loadedLink as? ReadLink)?.isRed, true)
    }
    
    func testStorage_removeLinkProperty_withParams() {
        // given
        let expect = expectation(description: "파라미터로 link 프로퍼티 삭제 업데이트")
        let dummy = ReadLink(link: "some")
            |> \.parentID .~ "p"
            |> \.remindTime .~ (.now() + 1000)
            |> \.isRed .~ true
        let params = ReadItemUpdateParams(item: dummy)
        
        // when
        let save = self.local.updateReadItems([dummy])
        let removeParams = params
            |> \.updatePropertyParams .~ [.remindTime(nil), .isRed(false), .parentID("new_parent_id")]
        let remove = self.local.updateItem(removeParams)
        let load = self.local.fetchCollectionItems("new_parent_id")
        let saveRemoveAndLoad = save.flatMap { remove }.flatMap { load }
        let loadedLink = self.waitFirstElement(expect, for: saveRemoveAndLoad.asObservable())?.first
        
        // then
        XCTAssertEqual(loadedLink?.remindTime, nil)
        XCTAssertEqual((loadedLink as? ReadLink)?.isRed, false)
        XCTAssertEqual(loadedLink?.parentID, "new_parent_id")
    }
    
    func testStorage_findItemUsingURL() {
        // given
        let expect = expectation(description: "url로 링크아이템 탐색")
        let link1 = ReadLink(link: self.dummyURL1)
        let link2 = ReadLink(link: self.dummyURL2)
        
        // when
        let save = self.local.updateReadItems([link1, link2])
        let find = self.local.findLinkItem(using: self.dummyURL1)
        let saveAndFind = save.flatMap { _ in find }
        let finded = self.waitFirstElement(expect, for: saveAndFind.asObservable())
        
        // then
        XCTAssertEqual(finded?.link, self.dummyURL1)
    }
    
    func testStorage_saveAndRemoveItems() {
        // given
        let expect = expectation(description: "read item 저장이후에 삭제")
        let collections = [ReadCollection(name: "c1"), ReadCollection(name: "c2")]
        let links: [ReadItem] = [ ReadLink(link: "l1"), ReadLink(link: "l2") ]
        let targetCollection = collections.first!
        let targetLink = links.last!
        
        // when
        let save = self.local.updateReadItems(collections + links)
        let removeCollection = self.local.removeItem(targetCollection)
        let removeLink = self.local.removeItem(targetLink)
        let load = self.local.fetchMyItems(memberID: nil)
        let saveRemoveAndLoad = save.flatMap { removeCollection }.flatMap { removeLink }.flatMap { load }
        let items = self.waitFirstElement(expect, for: saveRemoveAndLoad.asObservable())
        
        // then
        let isCollectionRemoved = items?.contains(where:  { $0.uid == targetCollection.uid }) == false
        let isLinkRemoved = items?.contains(where: { $0.uid == targetLink.uid }) == false
        XCTAssertEqual(items?.isNotEmpty, true)
        XCTAssertEqual(isCollectionRemoved, true)
        XCTAssertEqual(isLinkRemoved, true)
    }
    
    private var dummyCollections: [ReadCollection] {
        let items1: [ReadCollection] = (0..<5).map {
            ReadCollection(name: "some:\($0)") |> \.remindTime .~ (.now() + 100 - TimeStamp($0))
        }
        let items2: [ReadCollection] = (5..<10).map { ReadCollection(name: "some:\($0)") }
        return items1 + items2
    }
    
    private var dummyLinks: [ReadLink] {
        let items1: [ReadLink] = (10..<15).map {
            ReadLink(link: "some:\($0)") |> \.remindTime .~ (.now() + 100 - TimeStamp($0))
        }
        let items2: [ReadLink] = (15..<20).map { ReadLink(link: "some:\($0)") }
        return items1 + items2
    }
    
    func testStorage_suggestNextItem() {
        // given
        let expect = expectation(description: "다음 읽음목록 로드(리마인더 존재)")
        let totalItems: [ReadItem] = self.dummyCollections + self.dummyLinks
        
        // when
        let update = self.local.updateReadItems(totalItems)
        let suggesting = self.local.suggestNextReadItems(size: 10)
        let updateAndSugeest = update.flatMap { suggesting }
        let items = self.waitFirstElement(expect, for: updateAndSugeest.asObservable())
        
        // then
        XCTAssertEqual(items?.count, 10)
    }
    
    func testStorage_fetchMatchingItemsByIDs() {
        // given
        let expect = expectation(description: "아이디 목록에 해당하는 아이템 로드")
        let collections = self.dummyCollections; let links = self.dummyLinks
        let totalItems: [ReadItem] = collections + links
        let targetIDs = [collections.randomElement()!.uid, links.randomElement()!.uid]
        
        // when
        let update = self.local.updateReadItems(totalItems)
        let load = self.local.fetchMathingItems(targetIDs)
        let updateAndLoad = update.flatMap { load }
        let items = self.waitFirstElement(expect, for: updateAndLoad.asObservable())
        
        // then
        let ids = items?.map { $0.uid }
        XCTAssertEqual(ids, targetIDs)
    }
    
    func testStorage_loadReadingItems() {
        // given
        let links = self.dummyLinks
        let target = links.randomElement()!
        
        // when
        self.local.updateLinkItemIsReading(id: target.uid, isReading: true)
        self.local.updateLinkItemIsReading(id: "dummy", isReading: true)
        let idsOn = self.local.readingLinkItemIDs()
        self.local.updateLinkItemIsReading(id: target.uid, isReading: false)
        let idsOff = self.local.readingLinkItemIDs()
        
        // then
        XCTAssertEqual(idsOn, [target.uid, "dummy"])
        XCTAssertEqual(idsOff, ["dummy"])
    }
    
    func testStorage_saveAndLoadFavoriteIDs() {
        // given
        let expect = expectation(description: "즐겨찾는 아이디 저정하고 로드")
        let dummies = (0..<10).map { "id:\($0)" }
        
        // when
        let saveAndLoad = self.local.replaceFavoriteItemIDs(dummies).flatMap {
            self.local.fetchFavoriteItemIDs()
        }
        let ids = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(ids, dummies)
    }
    
    func testStorage_saveandToggleUpdateFavoriteIDs() {
        // given
        let expect = expectation(description: "즐겨찾는 아이디 저정하고 로드")
        let dummies = (0..<10).map { "id:\($0)" }
        
        // when
        let saveToggleAndLoad = self.local.replaceFavoriteItemIDs(dummies)
            .flatMap { self.local.toggleItemIsFavorite("id:3", isOn: false) }
            .flatMap { self.local.toggleItemIsFavorite("new", isOn: true) }
            .flatMap { self.local.fetchFavoriteItemIDs() }
        let ids = self.waitFirstElement(expect, for: saveToggleAndLoad.asObservable())
        
        // then
        XCTAssertEqual(ids, dummies.filter { $0 != "id:3" } + ["new"])
    }
    
    private var dummyURL1: String {
        return """
        https://www.google.co.kr/search?q=swift+cg+animation&newwindow=1&bih=895&biw=1530&hl=ko&sxsrf=AOaemvLLuvpHGCDsyor5jBU4_d6NjW-1Og%3A1635659653056&ei=hS9-YYHXAs22mAWfqriQDg&oq=swift+cg+animation&gs_lcp=Cgdnd3Mtd2l6EAMyBQghEKABMgUIIRCgAToECCMQJzoECAAQQzoHCAAQgAQQCjoICAAQgAQQsQM6BwgAELEDEEM6CggAEIAEEIcCEBQ6BQgAEIAEOgcIIxCxAhAnOgQIABAKOgcIIRAKEKABOgQIIRAVSgQIQRgBUOf6J1iiiihgqowoaANwAHgAgAGZAYgB9xCSAQQwLjE4mAEAoAEBwAEB&sclient=gws-wiz&ved=0ahUKEwjBrd-E-_PzAhVNG6YKHR8VDuIQ4dUDCA4&uact=5
        """
    }
    
    private var dummyURL2: String {
        return """
        https://www.google.co.kr/search?q=firebase+fcm+send+message+schedule+date&btnK=Google+%EA%B2%80%EC%83%89&newwindow=1&bih=944&biw=1397&hl=ko&sxsrf=AOaemvKTvpUqMZEaJ4CoS4essjh2eq2a-A%3A1635250959171&source=hp&ei=D_N3YZfHB8j2-gScj5nAAQ&iflsig=ALs-wAMAAAAAYXgBH9jwr5bCJvLc8KggQtK7uRbMstAN&ved=0ahUKEwjXiqbEiOjzAhVIu54KHZxHBhgQ4dUDCAc&uact=5&oq=ribs+git&gs_lcp=Cgdnd3Mtd2l6EAMyBAgjECcyBQgAEIAEMgYIABAFEB4yBggAEAgQHjoGCCMQJxATOgsIABCABBCxAxCDAToECAAQQzoHCCMQsQIQJzoICAAQgAQQsQM6BwgjEOoCECc6CggAEIAEEIcCEBQ6BAgAEB5Q-ghYoiRg0CVoA3AAeACAAXmIAcUJkgEEMC4xMZgBAKABAbABCg&sclient=gws-wiz
        """
    }
    
    func testStorage_updateAndLoadIsNeedRealod() {
        // given
        // when
        let reloadNeedIDsBeforeUpdate = self.local.fetchReloadNeedCollectionIDs()
        self.local.updateIsReloadNeedCollectionIDs(["c1", "c2"])
        let reloadNeedIDsAfterUpdate = self.local.fetchReloadNeedCollectionIDs()
        
        // then
        XCTAssertEqual(reloadNeedIDsBeforeUpdate, [])
        XCTAssertEqual(reloadNeedIDsAfterUpdate, ["c1", "c2"])
    }
}


extension LocalStorageTests_ReadItem {
    
    func testStorage_suggestReadItems() {
        // given
        let expect = expectation(description: "readitem 탐색")
        let collection = ReadCollection(name: "target")
        let linkWithCustomName = ReadLink(link: self.dummyURL2) |> \.customName .~ "tar_custom"
        let linkWithoutCustomName = ReadLink(link: self.dummyURL1)
        let preview = LinkPreview(title: "tar_preview", description: nil, mainImageURL: nil, iconURL: nil)
        
        // when
        let saveItems = self.local.updateReadItems([collection, linkWithCustomName, linkWithoutCustomName])
        let savePreview = self.local.saveLinkPreview(for: self.dummyURL1, preview: preview)
        let find = self.local.searchReadItems("ta")
        let saveAndFind = saveItems.flatMap { savePreview }.flatMap { find }
        let indexes = self.waitFirstElement(expect, for: saveAndFind.asObservable())
        
        // then
        XCTAssertEqual(indexes?.count, 3)
    }
}

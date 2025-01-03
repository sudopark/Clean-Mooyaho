//
//  DataModelStorage.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxSwiftDoNotation
import SQLiteService
import Prelude
import Optics

import Domain
import Extensions


// MARK: - DataModelStorage

public protocol DataModelStorage: Sendable {
    
    var dbPath: String { get }
    
    func openDatabase() -> Maybe<Void>
    
    func closeDatabase() -> Maybe<Void>
    
    func fetchMember(for memberID: String) -> Maybe<Member?>
    
    func fetchMembers(_ memberIDs: [String]) -> Maybe<[Member]>
    
    func save(member: Member) -> Maybe<Void>
    
    func insertOrUpdateMembers(_ members: [Member]) -> Maybe<Void>
    
    func updateMember(_ member: Member) -> Maybe<Void>
    
    func fetchMyReadItems() -> Maybe<[ReadItem]>
    
    func removeMyReadItems() -> Maybe<Void>
    
    func fetchReadCollectionItems(_ collectionID: String) -> Maybe<[ReadItem]>
    
    func removeReadCollectionItems(_ collectionID: String) -> Maybe<Void>
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?>
    
    func fetchReadLink(_ linkID: String) -> Maybe<ReadLink?>
    
    func updateReadCollections(_ collections: [ReadCollection]) -> Maybe<Void>
    
    func updateReadLinks(_ links: [ReadLink]) -> Maybe<Void>
    
    func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func findLinkItem(using url: String) -> Maybe<ReadLink?>
    
    func removeReadItem(_ item: ReadItem) -> Maybe<Void>
    
    func fetchReadItem(like name: String) -> Maybe<[SearchReadItemIndex]>
    
    func fetchUpcommingItems() -> Maybe<[ReadItem]>
    
    func fetchMatchingItems(in ids: [String]) -> Maybe<[ReadItem]>
    
    func fetchFavoritemItemIDs() -> Maybe<[String]>
    
    func replaceFavoriteItemIDs(_ ids: [String]) -> Maybe<Void>
    
    func fetchLinkPreview(_ url: String) -> Maybe<LinkPreview?>
    
    func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void>
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func updateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void>
    
    func fetchingItemCategories(like name: String) -> Maybe<[ItemCategory]>
    
    func fetchLatestItemCategories() -> Maybe<[ItemCategory]>
    
    func fetchCategories(earilerThan creatTime: TimeStamp, pageSize: Int) -> Maybe<[ItemCategory]>
    
    func deleteCategory(_ itemID: String) -> Maybe<Void>
    
    func findCategory(by name: String) -> Maybe<ItemCategory?>
    
    func fetchMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?>
    
    func updateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void>
    
    func deleteMemo(for linkItemID: String) -> Maybe<Void>
    
    func fetch<T>(_ type: T.Type, with size: Int) -> Maybe<[T]>
    
    func remove<T>(_ type: T.Type, in ids: [String]) -> Maybe<Void>
    
    func save<T>(_ type: T.Type, _ models: [T]) -> Maybe<Void>
    
    func fetchLatestSharedCollections() -> Maybe<[SharedReadCollection]>
    
    func replaceLastSharedCollections(_ collections: [SharedReadCollection]) -> Maybe<Void>
    
    func saveSharedCollection(_ collection: SharedReadCollection) -> Maybe<Void>
    
    func fetchMySharingItemIDs() -> Maybe<[String]>
    
    func updateMySharingItemIDs(_ ids: [String]) -> Maybe<Void>
    
    func removeSharedCollection(shareID: String) -> Maybe<Void>
    
    func fetchLatestSearchQueries() -> Maybe<[LatestSearchedQuery]>
    
    func insertLatestSearchQuery(_ query: String) -> Maybe<Void>
    
    func removeLatestSearchQuery(_ query: String) -> Maybe<Void>
    
    func fetchAllSuggestableQueries() -> Maybe<[String]>
    
    func insertSuggestableQueries(_ queries: [String]) -> Maybe<Void>
    
    func fetchLastReadPosition(for itemID: String) -> Maybe<ReadPosition?>
    
    func updateLastReadPosition(for itemID: String, _ position: Double) -> Maybe<ReadPosition>
}


// MARK: - DataModelStorageImple

public final class DataModelStorageImple: DataModelStorage, @unchecked Sendable {
    
    let sqliteService: SQLiteService
    
    public let dbPath: String
    private let version: Int
    
    private let disposeBag = DisposeBag()
    private let closeWhenDeinit: Bool
    
    var isOpen = false
    
    public init(dbPath: String, version: Int = 0, closeWhenDeinit: Bool = true) {
        
        self.dbPath = dbPath
        self.version = version
        
        self.sqliteService = SQLiteService()
        self.closeWhenDeinit = closeWhenDeinit
    }
    
    deinit {
        closeWhenDeinit.then {
            self.sqliteService.close()
        }
    }
    
    public func openDatabase() -> Maybe<Void> {
        
        guard self.isOpen == false else { return .just() }
        
        let updateFlag: () -> Void = { [weak self] in
            self?.isOpen = true
        }
        
        let startMigration: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.migrationPlan(for: self.version)
                .subscribe(onSuccess: { dbVersion in
                    let secureMessaging = SecureLoggingMessage()
                        |> \.fullText .~ "sqlite db open, version: \(dbVersion) and path: %@"
                        |> \.secureField .~ [self.dbPath]
                    logger.print(level: .info, secureMessaging)
                })
                .disposed(by: self.disposeBag)
        }
        
        let logError: (Error) -> Void = { [weak self] error in
            guard let self = self else { return }
            let secureMessaging = SecureLoggingMessage()
                |> \.fullText .~ "fail to open sqlite database -> path: %@ and reason: \(error)"
                |> \.secureField .~ [self.dbPath]
            logger.print(level: .error, secureMessaging)
        }
        
        return self.openAction()
            .do(onNext: updateFlag)
            .do(onNext: startMigration, onError: logError)
    }
    
    private func openAction() -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            let result = self.sqliteService.open(path: self.dbPath)
            switch result {
            case .success:
                callback(.success(()))
                
            case let .failure(error):
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    public func closeDatabase() -> Maybe<Void> {
        
        guard self.isOpen == true else { return .just() }
        
        let updateFlag: () -> Void = { [weak self] in
            self?.isOpen = false
        }
        return self.closeAction()
            .do(onNext: updateFlag)
    }
    
    private func closeAction() -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            self.sqliteService.open(path: self.dbPath) { result in
                switch result {
                case .success:
                    callback(.success(()))
                    
                case let .failure(error):
                    callback(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}


// DataModelStorageImple - Member

extension DataModelStorageImple {
    
    public func fetchMember(for memberID: String) -> Maybe<Member?> {
        return self.fetchMembers([memberID])
            .map{ $0.first }
    }
    
    public func fetchMembers(_ memberIDs: [String]) -> Maybe<[Member]> {
        
        let memberQuery = MemberTable.selectAll{ $0.uid.in(memberIDs) }
        let imageQuery = ThumbnailTable.selectAll()
        let joinQuery = memberQuery.outerJoin(with: imageQuery, on: { ($0.uid, $1.ownerID) })
        
        let mapping: (CursorIterator) throws -> (Member) = { cursor in
            let memberEntity = try MemberTable.Entity(cursor)
            let iconEntity = try? ThumbnailTable.Entity(cursor)
            var member = Member(uid: memberEntity.uid, nickName: memberEntity.nickName)
            member.introduction = memberEntity.introduction
            member.icon = iconEntity?.thumbnail
            member.deactivatedDateTimeStamp = memberEntity.deactivatedAt
            return member
        }
        
        return self.sqliteService.rx.run {
            try $0.load(joinQuery, mapping: mapping)
        }
    }
    
    public func save(member: Member) -> Maybe<Void> {
        
        return self.insertOrUpdateMembers([member])
    }
    
    public func insertOrUpdateMembers(_ members: [Member]) -> Maybe<Void> {
        
        let (memberTable, imageTable) = (MemberTable.self, ThumbnailTable.self)
        let memberEntities = members.map{ $0.asEntity() }
        let iconEntities = members.compactMap{ $0.iconEntity() }
        
        let insertMembers = self.sqliteService.rx
            .run{ try $0.insert(memberTable, entities: memberEntities) }
        let thenInsertIcons: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.rx.run { try $0.insert(imageTable, entities: iconEntities)}
                .catchAndReturn(())
        }
        
        return insertMembers
            .flatMap(thenInsertIcons)
    }
    
    public func updateMember(_ member: Member) -> Maybe<Void> {
        let memberEntity = MemberTable.Entity(member)
        let updateMember = self.sqliteService.rx
            .run { try $0.insert(MemberTable.self, entities: [memberEntity]) }
        
        let thenUpdateIcon: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return member.icon.map { self.insertIcon($0, for: member.uid) }
                ?? self.deleteIcon(for: member.uid)
        }
        return updateMember
            .flatMap(thenUpdateIcon)
    }
    
    private func insertIcon(_ icon: Thumbnail, for memberID: String) -> Maybe<Void> {
        let entity = ThumbnailTable.Entity(memberID, thumbnail: icon)
        return self.sqliteService.rx.run { try $0.insert(ThumbnailTable.self, entities: [entity]) }
            .catchAndReturn(())
    }
    
    private func deleteIcon(for memberID: String) -> Maybe<Void> {
        let query = ThumbnailTable.delete()
            .where { $0.ownerID == memberID }
        return self.sqliteService.rx.run { try $0.delete(ThumbnailTable.self, query: query) }
            .catchAndReturn(())
    }
}


// MARK: - Read Item

extension DataModelStorageImple {

    public func fetchMyReadItems() -> Maybe<[ReadItem]> {
        let linkQuery = ReadLinkTable.selectAll { $0.parentID.isNull() }
        let collectionQuery = ReadCollectionTable.selectAll { $0.parentID.isNull() }
        return self.fetchMatchingItems(linkQuery, collectionQuery)
    }
    
    public func removeMyReadItems() -> Maybe<Void> {
        let linksQuery = ReadLinkTable.delete().where { $0.parentID.isNull() }
        let collectionsQuery = ReadCollectionTable.delete().where { $0.parentID.isNull() }
        return self.removeMatchingItems(linksQuery, collectionsQuery)
    }
    
    public func fetchReadCollectionItems(_ collectionID: String) -> Maybe<[ReadItem]> {
        let linkQuery = ReadLinkTable.selectAll { $0.parentID == collectionID }
        let collectionQuery = ReadCollectionTable.selectAll { $0.parentID == collectionID }
        return self.fetchMatchingItems(linkQuery, collectionQuery)
    }
    
    public func removeReadCollectionItems(_ collectionID: String) -> Maybe<Void> {
        let linksQuery = ReadLinkTable.delete().where {$0.parentID == collectionID }
        let collectionsQuery = ReadCollectionTable.delete().where { $0.parentID == collectionID }
        return self.removeMatchingItems(linksQuery, collectionsQuery)
    }
    
    public func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?> {
        let query = ReadCollectionTable.selectAll { $0.uid == collectionID }
        return self.fetchReadCollections(query)
            .map { $0.first }
    }
    
    public func fetchReadLink(_ linkID: String) -> Maybe<ReadLink?> {
        let query = ReadLinkTable.selectAll { $0.uid == linkID }
        return self.fetchReadLinks(query)
            .map { $0.first }
    }
    
    private func fetchMatchingItems(_ linksQuery: SelectQuery<ReadLinkTable>,
                                    _ collectionQuery: SelectQuery<ReadCollectionTable>) -> Maybe<[ReadItem]> {
        
        let fetchCollections = self.fetchReadCollections(collectionQuery).catchAndReturn([])
        
        let thenLoadLinksAndMerge: @Sendable ([ReadCollection]) async throws -> [ReadItem]?
        thenLoadLinksAndMerge = { [weak self] collections in
            let links = try await self?.fetchReadLinks(linksQuery).value
            return collections + (links ?? [])
        }
        
        return fetchCollections
            .flatMap(do: thenLoadLinksAndMerge)
    }
    
    private func removeMatchingItems(
        _ linkQuery: DeleteQuery<ReadLinkTable>,
        _ collectionQuery: DeleteQuery<ReadCollectionTable>
    ) -> Maybe<Void> {
     
        let runRemove: @Sendable () async throws -> Void? = { [weak self] in
            try await self?.sqliteService.async.run {
                try $0.delete(ReadLinkTable.self, query: linkQuery)
            }
            try await self?.sqliteService.async.run {
                try $0.delete(ReadCollectionTable.self, query: collectionQuery)
            }
            return ()
        }
        return .just()
            .flatMap(do: runRemove)
    }
    
    private func fetchReadLinks(_ query: SelectQuery<ReadLinkTable>) -> Maybe<[ReadLink]> {
        let mapping: (CursorIterator) throws -> ReadLink = { cursor in
            return try ReadLinkTable.Entity(cursor).asLinkItem()
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    private func fetchReadCollections(_ query: SelectQuery<ReadCollectionTable>) -> Maybe<[ReadCollection]> {
        let mappging: (CursorIterator) throws -> ReadCollection = { cursor in
            return try ReadCollectionTable.Entity(cursor).asCollection()
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mappging) }
    }

    public func updateReadCollections(_ collections: [ReadCollection]) -> Maybe<Void> {
        
        typealias Entity = ReadCollectionTable.Entity
        let entities = collections.map{ Entity(collection: $0) }
        return self.sqliteService.rx.run { try $0.insert(ReadCollectionTable.self, entities: entities) }
    }
    
    public func updateReadLinks(_ links: [ReadLink]) -> Maybe<Void> {
        typealias Entity = ReadLinkTable.Entity
        let entities = links.map{ Entity(link: $0) }
        return self.sqliteService.rx.run { try $0.insert(ReadLinkTable.self, entities: entities) }
    }
    
    public func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        
        func updateCollection() -> Maybe<Void> {
            let query = ReadCollectionTable.update(replace: params.updateCollectionConditions(_:))
            return self.sqliteService.rx.run { try $0.update(ReadCollectionTable.self, query: query) }
        }
        
        func updateLink() -> Maybe<Void> {
            let query = ReadLinkTable.update(replace: params.updateLinkConditions(_:))
            return self.sqliteService.rx.run { try $0.update(ReadLinkTable.self, query: query) }
        }
        
        switch params.item {
        case is ReadCollection:
            return updateCollection()
        case is ReadLink:
            return updateLink()
            
        default: return .empty()
        }
    }
    
    public func findLinkItem(using url: String) -> Maybe<ReadLink?> {
        let query = ReadLinkTable.selectAll { $0.link == url }
        
        let mapping: (CursorIterator) throws -> ReadLink = { cursor in
            return try ReadLinkTable.Entity(cursor).asLinkItem()
        }
        return self.sqliteService.rx.run { try $0.loadOne(query, mapping: mapping) }
    }
    
    public func removeReadItem(_ item: ReadItem) -> Maybe<Void> {
        switch item {
        case is ReadCollection:
            let query = ReadCollectionTable.delete().where { $0.uid == item.uid }
            return self.sqliteService.rx.run { try $0.delete(ReadCollectionTable.self, query: query) }
            
        case is ReadLink:
            let query = ReadLinkTable.delete().where { $0.uid == item.uid }
            return self.sqliteService.rx.run { try $0.delete(ReadLinkTable.self, query: query) }
            
        default: return .error(LocalErrors.invalidData("not a collection or link"))
        }
    }
    
    public func fetchReadItem(like name: String) -> Maybe<[SearchReadItemIndex]> {
        
        let findingItems: Maybe<[ReadItem]> = Maybe.just()
            .flatMap { [weak self] in
                guard let self = self else { return nil }
                let collections = try? await self.findCollection(like: name).value
                let links = try? await self.findReadLink(like: name).value
                return (collections ?? []) + (links ?? [])
            }
        
        let asIndexes: ([ReadItem]) -> [SearchReadItemIndex] = { items in
            return items.compactMap { SearchReadItemIndex(item: $0) }
        }
        
        return findingItems
            .map(asIndexes)
    }
    
    private func findCollection(like name: String) -> Maybe<[ReadCollection]> {
        let query = ReadCollectionTable.selectAll { $0.name.like( "\(name)%" ) }
        let mappging: (CursorIterator) throws -> ReadCollection = { cursor in
            return try ReadCollectionTable.Entity(cursor).asCollection()
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mappging) }
    }
    
    private func findReadLink(like name: String) -> Maybe<[ReadLink]> {
        
        let findLikeCustomNames = self.findReadLinkByCustomName(like: name).catchAndReturn([])
        
        let thenFindLikePreviewTitleAndMerge: @Sendable ([ReadLink]) async throws -> ([ReadLink], [ReadLink])?
        thenFindLikePreviewTitleAndMerge = { [weak self] linksLikeCustomName in
            guard let self = self else { return nil }
            let linksLikePreviewTitle = try? await self.findReadLinkByPreviewTitle(like: name).value
            return (linksLikeCustomName, linksLikePreviewTitle ?? [])
        }
        
        let removeDuplicated: ([ReadLink], [ReadLink]) -> [ReadLink] = { customs, previews in
            let customMap = customs.reduce(into: [String: ReadLink]()) { $0[$1.uid] = $1 }
            return customs + previews.filter { customMap[$0.uid] == nil }
        }
        
        return findLikeCustomNames
            .flatMap(do: thenFindLikePreviewTitleAndMerge)
            .map(removeDuplicated)
    }
    
    private func findReadLinkByCustomName(like name: String) -> Maybe<[ReadLink]> {
        let query = ReadLinkTable.selectAll { $0.customName.like("\(name)%") }
        let mapping: (CursorIterator) throws -> ReadLink = { cursor in
            return try ReadLinkTable.Entity(cursor).asLinkItem()
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    private func findReadLinkByPreviewTitle(like name: String) -> Maybe<[ReadLink]> {
        typealias PreviewEntity = LinkPreviewTable.Entity
        let previewQuery = LinkPreviewTable.selectAll { $0.title.like("\(name)%") }
        let loadPreviews: Maybe<[PreviewEntity]> = self.sqliteService.rx.run { try $0.load(previewQuery) }
        
        let thenLoadMatchLinks: ([PreviewEntity]) -> Maybe<[ReadLink]> = { [weak self] previews in
            guard let self = self else { return .empty() }
            let urls = previews.map { $0.url }
            let previewMap = previews.reduce(into: [String: LinkPreview]()) { $0[$1.url] = $1.preview }
            
            let query = ReadLinkTable.selectAll { $0.link.in(urls) }
            let mapping: (CursorIterator) throws -> ReadLink = { try ReadLinkTable.Entity($0).asLinkItem() }
            let linkItems: Maybe<[ReadLink]> = self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
            let applyTitle: ([ReadLink]) -> [ReadLink] = { links in
                return links.map { $0 |> \.customName .~ previewMap[$0.link]?.title }
            }
            return linkItems.map(applyTitle)
        }
        
        return loadPreviews
            .flatMap(thenLoadMatchLinks)
    }
    
    public func fetchUpcommingItems() -> Maybe<[ReadItem]> {
        let now: TimeStamp = .now()
        let collectionQuery = ReadCollectionTable.selectAll { $0.remindTime > now }
        let linkQuery = ReadLinkTable.selectAll { $0.remindTime > now && $0.isRed == false }
        
        let orderItems: ([ReadItem]) -> [ReadItem] = { items in
            return items.sorted(by: { ($0.remindTime ?? 0) < ($1.remindTime ?? 0) })
        }
        
        return fetchMatchingItems(linkQuery, collectionQuery)
            .map(orderItems)
    }
    
    public func fetchMatchingItems(in ids: [String]) -> Maybe<[ReadItem]> {
        let collectionQuery = ReadCollectionTable.selectAll { $0.uid.in(ids) }
        let linkQuery = ReadLinkTable.selectAll { $0.uid.in(ids) }
        let orderItems: ([ReadItem]) -> [ReadItem] = { items in
            let itemsMap = items.reduce(into: [String: ReadItem]()) { $0[$1.uid] = $1 }
            return ids.compactMap { itemsMap[$0] }
        }
        return fetchMatchingItems(linkQuery, collectionQuery)
            .map(orderItems)
    }
    
    public func fetchFavoritemItemIDs() -> Maybe<[String]> {
        let query = FavoriteItemIDTable.selectAll()
        let mapping: (CursorIterator) throws -> String = {
            return try $0.next().unwrap()
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    public func replaceFavoriteItemIDs(_ ids: [String]) -> Maybe<Void> {
        let drop = self.sqliteService.rx.run { try $0.dropTable(FavoriteItemIDTable.self) }
        let thenSave: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            let entities = ids.map { FavoriteItemIDTable.Entity(id: $0) }
            return self.sqliteService.rx.run { try $0.insert(FavoriteItemIDTable.self, entities: entities) }
        }
        return drop.flatMap(thenSave)
    }
}


// MARK: - LinkPreview

extension DataModelStorageImple {
    
    public func fetchLinkPreview(_ url: String) -> Maybe<LinkPreview?> {
        let previews = LinkPreviewTable.self
        let query = previews.selectAll { $0.url == url }
        let mapping: (CursorIterator) throws -> LinkPreview = {
            let entitry = try LinkPreviewTable.Entity($0)
            return entitry.preview
        }
        return self.sqliteService.rx.run { try $0.loadOne(query, mapping: mapping) }
    }
    
    public func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void> {
        let entity = LinkPreviewTable.Entity(url: url , preview: preview)
        return self.sqliteService.rx
            .run { try $0.insertOne(LinkPreviewTable.self, entity: entity, shouldReplace: true) }
    }
}


// MARK: - ItemCategory

extension DataModelStorageImple {
    
    public func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        let query = ItemCategoriesTable.selectAll { $0.itemID.in(ids) }
        return self.sqliteService.rx.run { try $0.load(query) }
    }
    
    public func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.sqliteService.rx.run {
            try $0.insert(ItemCategoriesTable.self, entities: categories, shouldReplace: true)
        }
    }
    
    public func updateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void> {
        
        let query = ItemCategoriesTable
            .update(replace: { column in
                let conditions: [QueryExpression.Condition?] = [
                    params.newName.map { column.name == $0 },
                    params.newColorCode.map { column.colorCode == $0}
                ]
                return conditions.compactMap { $0 }
            })
            .where { $0.itemID == params.uid }
        return self.sqliteService.rx.run { try $0.update(ItemCategoriesTable.self, query: query) }
    }
    
    public func fetchingItemCategories(like name: String) -> Maybe<[ItemCategory]> {
        let query = ItemCategoriesTable.selectAll { $0.name.like( "\(name)%" ) }
        return self.sqliteService.rx.run { try $0.load(query) }
    }
    
    public func fetchLatestItemCategories() -> Maybe<[ItemCategory]> {
        let query = ItemCategoriesTable.selectAll().limit(100).orderBy("rowid", isAscending: false)
        return self.sqliteService.rx.run { try $0.load(query) }
    }
    
    public func fetchCategories(earilerThan creatTime: TimeStamp,
                                pageSize: Int) -> Maybe<[ItemCategory]> {
        
        let query = ItemCategoriesTable
            .selectAll { $0.createAt < creatTime }
            .orderBy(isAscending: false) { $0.createAt }
            .limit(pageSize)
        
        return self.sqliteService.rx.run { try $0.load(query) }
    }
    
    public func deleteCategory(_ itemID: String) -> Maybe<Void> {
        let query = ItemCategoriesTable.delete()
            .where { $0.itemID == itemID }
        return self.sqliteService.rx.run { try $0.delete(ItemCategoriesTable.self, query: query) }
    }
    
    public func findCategory(by name: String) -> Maybe<ItemCategory?> {
        let query = ItemCategoriesTable
            .selectAll { $0.name == name }
        return self.sqliteService.rx.run { try $0.loadOne(query) }
    }
}


// MARK: - ReadLinkMemo

extension DataModelStorageImple {
    
    public func fetchMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        let query = ReadLinkMemoTable.selectAll { $0.itemID == linkItemID }
        return self.sqliteService.rx.run { try $0.loadOne(query) }
    }
    
    public func updateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        return self.sqliteService.rx.run {
            try $0.insert(ReadLinkMemoTable.self, entities: [newValue], shouldReplace: true)
        }
    }
    
    public func deleteMemo(for linkItemID: String) -> Maybe<Void> {
        let query = ReadLinkMemoTable.delete().where { $0.itemID == linkItemID }
        return self.sqliteService.rx.run { try $0.delete(ReadLinkMemoTable.self, query: query) }
    }
}

// MARK: - ReadingOption

extension DataModelStorageImple {
    
    public func fetchLastReadPosition(for itemID: String) -> Maybe<ReadPosition?> {
        let query = ReadPositionTable.selectAll { $0.itemID == itemID }
        return self.sqliteService.rx.run { try $0.loadOne(query) }
    }
    
    public func updateLastReadPosition(for itemID: String, _ position: Double) -> Maybe<ReadPosition> {
        let position = ReadPosition(itemID: itemID, position: position)
        return self.sqliteService.rx
            .run { try $0.insert(ReadPositionTable.self, entities: [position], shouldReplace: true) }
            .map { position }
    }
}

// MARK: - shared item

extension DataModelStorageImple {
    
    public func fetchLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        let query = SharedRootReadCollectionTable.selectAll()
            .orderBy(isAscending: false) { $0.lastOpened }
            .orderBy("rowid", isAscending: false)
            .limit(20)
        let mapping: (CursorIterator) throws -> SharedReadCollection = { cursor in
            return try SharedRootReadCollectionTable.Entity(cursor).asCollection()
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    public func replaceLastSharedCollections(_ collections: [SharedReadCollection]) -> Maybe<Void> {
        let entities = collections.compactMap { SharedRootReadCollectionTable.Entity(collection: $0) }
        
        let dropTable = self.sqliteService.rx.run { try $0.dropTable(SharedRootReadCollectionTable.self) }
        let thenUpdateCollections: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.rx.run
                { try $0.insert(SharedRootReadCollectionTable.self, entities: entities, shouldReplace: true) }
        }
        return dropTable
            .flatMap(thenUpdateCollections)
    }
    
    public func saveSharedCollection(_ collection: SharedReadCollection) -> Maybe<Void> {
        guard let entity = SharedRootReadCollectionTable.Entity(collection: collection)else {
            return .error(ApplicationErrors.invalid)
        }
        return self.sqliteService.rx.run
            { try $0.insert(SharedRootReadCollectionTable.self, entities: [entity], shouldReplace: true) }
    }
    
    public func fetchMySharingItemIDs() -> Maybe<[String]> {
        let query = SharingCollectionIDsTable.selectAll()
        let mapping: (CursorIterator) throws -> String = {
            return try SharingCollectionIDsTable.Entity($0).collectionID
        }
        return self.sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    public func updateMySharingItemIDs(_ ids: [String]) -> Maybe<Void> {
        
        let dropTable = self.sqliteService.rx.run { try $0.dropTable(SharingCollectionIDsTable.self) }
        let andUpdate: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            let entities = ids.map { SharingCollectionIDsTable.Entity($0) }
            return self.sqliteService.rx.run { try $0.insert(SharingCollectionIDsTable.self, entities: entities) }
        }
        return dropTable
            .flatMap(andUpdate)
    }
    
    public func removeSharedCollection(shareID: String) -> Maybe<Void> {
        let collections = SharedRootReadCollectionTable.self
        let query = collections.delete().where { $0.shareID == shareID }
        return self.sqliteService.rx.run { try $0.delete(collections, query: query) }
    }
}


// MARK: - search query

extension DataModelStorageImple {
    
    public func fetchLatestSearchQueries() -> Maybe<[LatestSearchedQuery]> {
        let query = LatestSearchQueryTable
            .selectAll()
            .orderBy(isAscending: false) { $0.time }
            .limit(50)
        return self.sqliteService.rx.run { try $0.load(query) }
    }
    
    public func insertLatestSearchQuery(_ query: String) -> Maybe<Void> {
        let entity = LatestSearchedQuery(text: query, time: .now())
        return self.sqliteService.rx.run {
            return try $0.insert(LatestSearchQueryTable.self, entities: [entity], shouldReplace: true)
        }
    }
    
    public func removeLatestSearchQuery(_ query: String) -> Maybe<Void> {
        let query = LatestSearchQueryTable.delete().where { $0.query == query }
        return self.sqliteService.rx.run { try $0.delete(LatestSearchQueryTable.self, query: query) }
    }
    
    public func fetchAllSuggestableQueries() -> Maybe<[String]> {
        let query = SuggestableQueryTable.selectAll()
        let mapping: (CursorIterator) throws -> String = { try SuggestableQueryTable.Entity($0).text }
        return sqliteService.rx.run { try $0.load(query, mapping: mapping) }
    }
    
    public func insertSuggestableQueries(_ queries: [String]) -> Maybe<Void> {
        let entities = queries.map { SuggestableQueryTable.Entity($0) }
        return self.sqliteService.rx
            .run { try $0.insert(SuggestableQueryTable.self, entities: entities, shouldReplace: true) }
    }
}

extension Member {
    
    func asEntity() -> MemberTable.Entity {
        return .init(self)
    }
    
    func iconEntity() -> ThumbnailTable.Entity? {
        
        let ownerID = self.uid
        return self.icon.map{ ThumbnailTable.Entity(ownerID, thumbnail: $0) }
    }
}

private extension Array where Element == String {
    
    func filtering(_ dict: [String: ItemCategory]) -> [ItemCategory] {
        return self.compactMap { dict[$0] }
    }
}


private extension ReadItemUpdateParams {
    
    func updateCollectionConditions(_ columType: ReadCollectionTable.Columns.Type) -> [QueryExpression.Condition] {
        return self.updatePropertyParams.compactMap { param -> QueryExpression.Condition? in
            switch param {
            case .remindTime(nil):
                return columType.remindTime == Optional<Double>.none
                
            case let .remindTime(time):
                return columType.remindTime == time
                
            default: return nil
            }
        }
    }
    
    func updateLinkConditions(_ columType: ReadLinkTable.Columns.Type) -> [QueryExpression.Condition] {
        return self.updatePropertyParams.compactMap { param -> QueryExpression.Condition? in
            switch param {
            case .remindTime(nil):
                return columType.remindTime == Optional<Double>.none
                
            case .parentID(nil):
                return columType.parentID == Optional<String>.none
                
            case let .remindTime(time):
                return columType.remindTime == time
                
            case let .isRed(flag):
                return columType.isRed == flag
                
            case let .parentID(id):
                return columType.parentID == id
            }
        }
    }
}


private extension SearchReadItemIndex {
    
    init?(item: ReadItem) {
        switch item {
        case let collection as ReadCollection:
            self.init(itemID: collection.uid, isCollection: true, displayName: collection.name)
            self.categoryIDs = collection.categoryIDs
            self.description = collection.collectionDescription
            
        case let link as ReadLink:
            guard let name = link.customName else { return nil }
            self.init(itemID: link.uid, isCollection: false, displayName: name)
            self.categoryIDs = link.categoryIDs
            
        default: return nil
        }
    }
}

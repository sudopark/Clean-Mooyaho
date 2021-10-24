//
//  DataModelStorage.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SQLiteService

import Domain
import Prelude
import Optics


// MARK: - DataModelStorage

public protocol DataModelStorage {
    
    func fetchMember(for memberID: String) -> Maybe<Member?>
    
    func fetchMembers(_ memberIDs: [String]) -> Maybe<[Member]>
    
    func save(member: Member) -> Maybe<Void>
    
    func insertOrUpdateMembers(_ members: [Member]) -> Maybe<Void>
    
    func updateMember(_ member: Member) -> Maybe<Void>
    
    func savePlace(_ place: Place) -> Maybe<Void>
    
    func fetchPlace(_ placeID: String) -> Maybe<Place?>
    
    func saveHoorays(_ hoorays: [Hooray]) -> Maybe<Void>
    
    func fetchHoorays(_ ids: [String]) -> Maybe<[Hooray]>
    
    func fetchLatestHoorays(for memberID: String, limit count: Int) -> Maybe<[Hooray]>
    
    func saveHoorayDetail(_ detail: HoorayDetail) -> Maybe<Void>
    
    func fetchHoorayDetail(_ id: String) -> Maybe<HoorayDetail?>
    
    func fetchMyReadItems() -> Maybe<[ReadItem]>
    
    func fetchReadCollectionItems(_ collectionID: String) -> Maybe<[ReadItem]>
    
    func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?>
    
    func updateReadCollections(_ collections: [ReadCollection]) -> Maybe<Void>
    
    func updateReadLinks(_ links: [ReadLink]) -> Maybe<Void>
    
    func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func fetchLinkPreview(_ url: String) -> Maybe<LinkPreview?>
    
    func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void>
    
    func fetchCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func updateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func fetchingItemCategories(like name: String) -> Maybe<[ItemCategory]>
    
    func fetchLatestItemCategories() -> Maybe<[ItemCategory]>
}


// MARK: - DataModelStorageImple

public final class DataModelStorageImple: DataModelStorage {
    
    let sqliteService: SQLiteService
    
    private let disposeBag = DisposeBag()
    private let closeWhenDeinit: Bool
    
    public init(dbPath: String, verstion: Int = 0, closeWhenDeinit: Bool = true) {
        
        self.sqliteService = SQLiteService()
        self.closeWhenDeinit = closeWhenDeinit
        self.openAndStartMigrationIfNeed(dbPath, version: verstion)
    }
    
    deinit {
        closeWhenDeinit.then {
            self.sqliteService.close()
        }
    }
    
    private func openAndStartMigrationIfNeed(_ path: String, version: Int) {
        
        let openResult = self.sqliteService.open(path: path)
        guard case .success = openResult else {
            logger.print(level: .error, "fail to open sqlite database -> path: \(path)")
            return
        }
        
        self.migrationPlan(for: version)
            .subscribe(onSuccess: { dbVersion in
                logger.print(level: .info, "sqlite db open, version: \(dbVersion) and path: \(path)")
            })
            .disposed(by: self.disposeBag)
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
        let members = MemberTable.self
        let updateMemberQuery = members.update {
            [ $0.nickName.equal(member.nickName), $0.intro.equal(member.introduction) ]
        }
        .where{ $0.uid == member.uid }
        
        let images = ThumbnailTable.self
        let updateIconQuery = images.update { [
            $0.isEmoji.equal(member.icon?.isEmoji),
            $0.path.equal(member.icon?.source?.path),
            $0.width.equal(member.icon?.source?.size?.width),
            $0.height.equal(member.icon?.source?.size?.height),
            $0.emoji.equal(member.icon?.emoji)
        ] }
        .where{ $0.ownerID == member.uid }
        
        let updateMember = self.sqliteService.rx.run{ try $0.update(members, query: updateMemberQuery) }
        let thenUpdateIcon: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.rx.run { try $0.update(images, query: updateIconQuery) }
                .catchAndReturn(())
        }
        return updateMember
            .flatMap(thenUpdateIcon)
    }
}


// MARK: - place

extension DataModelStorageImple {
    
    public func savePlace(_ place: Place) -> Maybe<Void> {
        
        let (places, images, tags) = (PlaceInfoTable.self, ImageSourceTable.self, TagTable.self)
        
        let placeInfo = places.EntityType(place: place)
        let savePlace = self.sqliteService.rx.run{ try $0.insert(places, entities: [placeInfo]) }
        let thenSaveThumbnails: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            let imageModel = ImageSourceTable.Entity(place.uid, source: place.thumbnail)
            return self.sqliteService.rx.run { try $0.insert(images, entities: [imageModel]) }
                .catchAndReturn(())
        }
        let thenSaveTags: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.rx.run { try $0.insert(tags, entities: place.placeCategoryTags) }
                .catchAndReturn(())
        }
        
        return savePlace
            .flatMap(thenSaveThumbnails)
            .flatMap(thenSaveTags)
    }
    
    public func fetchPlace(_ placeID: String) -> Maybe<Place?> {
        
        typealias PlaceInfo = PlaceInfoTable.Entity
        
        let (places, images, tags) = (PlaceInfoTable.self, ImageSourceTable.self, TagTable.self)
        
        let placeQuery = places.selectAll{ $0.uid == placeID }
        let imageQuery = images.selectAll()
        let joinQuery = placeQuery.outerJoin(with: imageQuery, on: { ($0.uid, $1.ownerID) })
       
        let fetchPlaceInfo = self.sqliteService.rx
            .run{ try $0.loadOne(joinQuery, mapping: CursorIterator.makePlaceInfoAndThumbnail) }
        
        let appendCategoryTagsOrNot: ((PlaceInfo, ImageSource?)?) -> Maybe<Place?> = { [weak self] pair in
            guard let self = self else { return .empty() }
            guard let pair = pair else { return .just(nil) }
            let tagsQuery = tags.selectAll{ $0.keyword.in(pair.0.categoryIDs) }
            let fetchTags = self.sqliteService.rx.run { try $0.load(tags, query: tagsQuery) }.catchAndReturn([])
            return fetchTags
                .map{ Place(info: pair.0, thumbnail: pair.1, tags: $0) }
        }
        
        return fetchPlaceInfo
            .flatMap(appendCategoryTagsOrNot)
    }
}


// MARK: - DataModelStorageImpl + Hooray

extension DataModelStorageImple {
    
    public func saveHoorays(_ hoorays: [Hooray]) -> Maybe<Void> {
        
        let hoorayEntities = hoorays.map{ HoorayTable.Entity($0) }
        let saveHoorays = self.sqliteService.rx.run { try $0.insert(HoorayTable.self, entities: hoorayEntities) }
        
        let thenSaveAdditionalInfos: () -> Void = { [weak self] in
            self?.saveHoorayImage(hoorays)
        }
        return saveHoorays
            .do(onNext: thenSaveAdditionalInfos)
    }
    
    private func saveHoorayImage(_ hoorays: [Hooray]) {
        let entities = hoorays.map{ ImageSourceTable.Entity($0.uid, source: $0.image) }
        self.sqliteService.rx.run { try $0.insert(ImageSourceTable.self, entities: entities) }
            .subscribe()
            .disposed(by: self.disposeBag)
    }

    public func fetchHoorays(_ ids: [String]) -> Maybe<[Hooray]> {
        
        let hooraysQuery = HoorayTable.selectAll { $0.uid.in(ids) }
        let imagesQuery = ImageSourceTable.selectAll { $0.ownerID.in(ids) }
        let joinQuery = hooraysQuery.outerJoin(with: imagesQuery, on: { ($0.uid, $1.ownerID) })
        return self.fetchHoorays(with: joinQuery)
    }
    
    public func fetchLatestHoorays(for memberID: String, limit count: Int) -> Maybe<[Hooray]> {
        let hoorayQuery = HoorayTable.selectAll { $0.publisherID == memberID }
            .orderBy(isAscending: false) { $0.timeStamp }
            .limit(count)
        let imageQuery = ImageSourceTable.selectAll()
        let joinQuery = hoorayQuery
            .outerJoin(with: imageQuery, on: { ($0.uid, $1.ownerID) })
        
        return self.fetchHoorays(with: joinQuery)
    }
    
    private func fetchHoorays(with joinQuery: JoinQuery<HoorayTable>) -> Maybe<[Hooray]> {
        let loadHoorays = self.sqliteService.rx.run { try $0.load(joinQuery, mapping: Hooray.fromImageSource(_:)) }
        return loadHoorays
    }
    
    public func saveHoorayDetail(_ detail: HoorayDetail) -> Maybe<Void> {
        
        let saveHoorayInfo = self.saveHoorays([detail.hoorayInfo])
        let thenSaveAcks: () -> Maybe<Void> = { [weak self] in
            return self?.saveHoorayAcks(detail.acks).catchAndReturn(()) ?? .empty()
        }
        let thenSaveReactions: () -> Maybe<Void> = { [weak self] in
            return self?.saveHoorayReactions(detail.reactions).catchAndReturn(()) ?? .empty()
        }
        
        return saveHoorayInfo
            .flatMap(thenSaveAcks)
            .flatMap(thenSaveReactions)
    }
    
    private func saveHoorayAcks(_ acks: [HoorayAckInfo]) -> Maybe<Void> {
        
        guard acks.isNotEmpty else { return .just() }
        
        let entities: [HoorayAckUserTable.Entity] = acks.map{ .init($0) }
        return self.sqliteService.rx.run {
            try $0.insert(HoorayAckUserTable.self, entities: entities)
        }
    }
    
    private func saveHoorayReactions(_ reactions: [HoorayReaction]) -> Maybe<Void> {
        
        guard reactions.isNotEmpty else { return .just() }
        
        let reactionEntities: [HoorayReactionTable.Entity] = reactions.map{ .init($0) }
        let saveReactions = self.sqliteService.rx.run {
            try $0.insert(HoorayReactionTable.self, entities: reactionEntities)
        }
        
        let thenSaveIcons: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            let iconEntities: [ThumbnailTable.Entity] = reactions.map{ .init($0.reactionID, thumbnail: $0.icon) }
            return self.sqliteService.rx.run{ try $0.insert(ThumbnailTable.self, entities: iconEntities) }
        }
        return saveReactions
            .flatMap(thenSaveIcons)
    }
    
    public func fetchHoorayDetail(_ id: String) -> Maybe<HoorayDetail?> {
        
        let hoorayInfo = self.fetchHoorays([id]).map{ $0.first }
        let thenAppendAcks: (Hooray?) -> Maybe<HoorayDetail?> = { [weak self] hooray in
            guard let hooray = hooray else { return .just(nil) }
            return self?.fetchHoorayAcks(id).catchAndReturn([])
                .map { HoorayDetail(info: hooray, acks: $0, reactions: []) } ?? .empty()
        }
        let thenAppendReactions: (HoorayDetail?) -> Maybe<HoorayDetail?> = { [weak self] detail in
            guard let detail = detail else { return .just(nil) }
            return self?.fetchHoorayReactions(id).catchAndReturn([])
                .map{ .init(info: detail.hoorayInfo, acks: detail.acks, reactions: $0) } ?? .empty()
        }
        return hoorayInfo
            .flatMap(thenAppendAcks)
            .flatMap(thenAppendReactions)
    }
    
    private func fetchHoorayAcks(_ id: String) -> Maybe<[HoorayAckInfo]> {
        let acks = HoorayAckUserTable.self
        let query = acks.selectAll { $0.hoorayID == id }
        return self.sqliteService.rx.run{ try $0.load(acks, query: query) }
            .map{ $0.asAcks() }
    }
    
    private func fetchHoorayReactions(_ id: String) -> Maybe<[HoorayReaction]> {
        let (reactions, images) = (HoorayReactionTable.self, ThumbnailTable.self)
        let reactionQuery = reactions.selectAll { $0.hoorayID == id }
        let iconsQuery = images.selectAll()
        let joinQuery = reactionQuery.outerJoin(with: iconsQuery, on: { ($0.reactionID, $1.ownerID) })
        
        return self.sqliteService.rx
            .run { try $0.load(joinQuery, mapping: HoorayReaction.mapWithIcon(_:)) }
            .map{ $0.sorted(by: { $0.reactAt < $1.reactAt })}
    }
}

// MARK: - Read Item

extension DataModelStorageImple {

    public func fetchMyReadItems() -> Maybe<[ReadItem]> {
        let linkQuery = ReadLinkTable.selectAll { $0.parentID.isNull() }
        let collectionQuery = ReadCollectionTable.selectAll { $0.parentID.isNull() }
        return self.fetchMatchingItems(linkQuery, collectionQuery)
    }
    
    public func fetchReadCollectionItems(_ collectionID: String) -> Maybe<[ReadItem]> {
        let linkQuery = ReadLinkTable.selectAll { $0.parentID == collectionID }
        let collectionQuery = ReadCollectionTable.selectAll { $0.parentID == collectionID }
        return self.fetchMatchingItems(linkQuery, collectionQuery)
    }
    
    public func fetchCollection(_ collectionID: String) -> Maybe<ReadCollection?> {
        let query = ReadCollectionTable.selectAll { $0.uid == collectionID }
        return self.fetchReadCollections(query)
            .map { $0.first }
    }
    
    private func fetchMatchingItems(_ linksQuery: SelectQuery<ReadLinkTable>,
                                    _ collectionQuery: SelectQuery<ReadCollectionTable>) -> Maybe<[ReadItem]> {
        
        let collections = self.fetchReadCollections(collectionQuery).catchAndReturn([]).asObservable()
        let links = self.fetchReadLinks(linksQuery).catchAndReturn([]).asObservable()

        let fetchBothWithoutError = Observable.combineLatest(collections, links)
        let mergeItems: ([ReadCollection], [ReadLink]) -> [ReadItem] = { $0 + $1 }
        return fetchBothWithoutError
            .map(mergeItems)
            .asMaybe()
        
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
    
    public func fetchingItemCategories(like name: String) -> Maybe<[ItemCategory]> {
        let query = ItemCategoriesTable.selectAll { $0.name.like( "\(name)%" ) }
        return self.sqliteService.rx.run { try $0.load(query) }
    }
    
    public func fetchLatestItemCategories() -> Maybe<[ItemCategory]> {
        let query = ItemCategoriesTable.selectAll().limit(100).orderBy("rowid", isAscending: false)
        return self.sqliteService.rx.run { try $0.load(query) }
    }
}


private extension CursorIterator {
    
    static func makePlaceInfoAndThumbnail(_ cursor: CursorIterator) throws -> (PlaceInfoTable.Entity, ImageSource?) {
        let placeInfo = try PlaceInfoTable.Entity(cursor)
        let thumbnail = try? ImageSourceTable.Entity(cursor).source
        return (placeInfo, thumbnail)
    }
}

private extension Place {
    
    init?(info: PlaceInfoTable.Entity, thumbnail: ImageSource?, tags: [Tag]) {
        self.init(uid: info.uid, title: info.title, thumbnail: thumbnail,
                  externalSearchID: info.externalSearchID, detailLink: info.detailLink,
                  coordinate: .init(latt: info.latt, long: info.long),
                  address: info.address, contact: info.contact, categoryTags: tags,
                  reporterID: info.reporterID, infoProvider: info.infoProvider,
                  createdAt: info.createAt, pickCount: info.placePickCount, lastPickedAt: info.lastPickedAt)
    }
}

extension Member {
    
    func asEntity() -> MemberTable.Entity {
        return .init(self.uid, nickName: self.nickName, intro: self.introduction)
    }
    
    func iconEntity() -> ThumbnailTable.Entity? {
        
        let ownerID = self.uid
        return self.icon.map{ ThumbnailTable.Entity(ownerID, thumbnail: $0) }
    }
}

private extension Hooray {
    
    static func fromImageSource(_ cursor: CursorIterator) throws -> Hooray {
        let entity = try HoorayTable.Entity(cursor)
        let imageEntity = try? ImageSourceTable.Entity(cursor)
        return Hooray(uid: entity.uid, placeID: entity.placeID, publisherID: entity.publisherID,
                      hoorayKeyword: .init(uid: entity.keywordID, text: entity.keywordText, soundSource: entity.keywordSource),
                      message: entity.message, tags: entity.tags, image: imageEntity?.source,
                      location: entity.coordinate, timestamp: entity.timeStamp,
                      spreadDistance: entity.spreadDistance, aliveDuration: entity.aliveTime)
    }
}

private extension Array where Element == HoorayAckUserTable.Entity {

    func asAcks() -> [HoorayAckInfo] {
        return self.map { entity in
            return .init(hoorayID: entity.hoorayID, ackUserID: entity.ackUserID, ackAt: entity.ackAt)
        }
    }
}

private extension HoorayReaction {
    
    static func mapWithIcon(_ cusrosr: CursorIterator) throws -> HoorayReaction {
        
        let entity = try HoorayReactionTable.Entity(cusrosr)
        guard let icon = try ThumbnailTable.Entity(cusrosr).thumbnail else {
            throw LocalErrors.deserializeFail(nil)
        }
        
        return .init(hoorayID: entity.hoorayID,
                     reactionID: entity.reactionID, reactMemberID: entity.memberID,
                     icon: icon, reactAt: entity.reactAt)
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
            }
        }
    }
    
    func updateLinkConditions(_ columType: ReadLinkTable.Columns.Type) -> [QueryExpression.Condition] {
        return self.updatePropertyParams.compactMap { param -> QueryExpression.Condition? in
            switch param {
            case .remindTime(nil):
                return columType.remindTime == Optional<Double>.none
                
            case let .remindTime(time):
                return columType.remindTime == time
            }
        }
    }
}

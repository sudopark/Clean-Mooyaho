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


// MARK: - DataModelStorage

public protocol DataModelStorage {
    
    func fetchMember(for memberID: String) -> Maybe<Member?>
    
    func fetchMembers(_ memberIDs: [String]) -> Maybe<[Member]>
    
    func save(member: Member) -> Maybe<Void>
    
    func insertOrUpdateMembers(_ members: [Member]) -> Maybe<Void>
    
    func updateMember(_ member: Member) -> Maybe<Void>
    
    func savePlace(_ place: Place) -> Maybe<Void>
    
    func fetchPlace(_ placeID: String) -> Maybe<Place?>
}


// MARK: - DataModelStorageImple

public class DataModelStorageImple: DataModelStorage {
    
    private let sqliteService: SQLiteService
    
    private let disposeBag = DisposeBag()
    
    public init(dbPath: String, verstion: Int = 0) {
        
        self.sqliteService = SQLiteService()
        self.openAndStartMigrationIfNeed(dbPath, version: verstion)
    }
    
    deinit {
        self.sqliteService.close()
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
        let imageQuery = ImageSourceTable.selectAll()
        
        let joinQuery = memberQuery.outerJoin(with: imageQuery, on: { ($0.uid, $1.ownerID) })
        let mapping: (CursorIterator) throws -> (Member) = { cursor in
            let memberEntity = try MemberTable.Entity(cursor)
            let iconEntity = try? ImageSourceTable.Entity(cursor)
            var member = Member(uid: memberEntity.uid, nickName: memberEntity.nickName)
            member.introduction = memberEntity.introduction
            member.icon = iconEntity?.source
            return member
        }
        
        return self.sqliteService.run{ try $0.load(joinQuery, mapping: mapping) }
    }
    
    public func save(member: Member) -> Maybe<Void> {
        
        return self.insertOrUpdateMembers([member])
    }
    
    public func insertOrUpdateMembers(_ members: [Member]) -> Maybe<Void> {
        
        let (memberTable, imageTable) = (MemberTable.self, ImageSourceTable.self)
        let memberEntities = members.map{ $0.asEntity() }
        let iconEntities = members.compactMap{ $0.iconEntity() }
        
        let insertMembers = self.sqliteService
            .run{ try $0.insert(memberTable, entities: memberEntities) }
        let thenInsertIcons: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.run { try $0.insert(imageTable, entities: iconEntities)}
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
        
        let images = ImageSourceTable.self
        let updateIconQuery = images.update {
            [$0.sourcetype.equal(member.icon?.type), $0.path.equal(member.icon?.path),
             $0.description.equal(member.icon?.description), $0.emoji.equal(member.icon?.emoji) ]
        }
        .where{ $0.ownerID == member.uid }
        
        let updateMember = self.sqliteService.run{ try $0.update(members, query: updateMemberQuery) }
        let thenUpdateIcon: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.run { try $0.update(images, query: updateIconQuery) }
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
        let savePlace = self.sqliteService.run{ try $0.insert(places, entities: [placeInfo]) }
        let thenSaveThumbnails: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            let imageModel = ImageSourceTable.Entity(place.reporterID, source: place.thumbnail)
            return self.sqliteService.run { try $0.insert(images, entities: [imageModel]) }
                .catchAndReturn(())
        }
        let thenSaveTags: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.run { try $0.insert(tags, entities: place.placeCategoryTags) }
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
        let imageQuery = images.selectSome{ [$0.sourcetype, $0.path, $0.description, $0.emoji] }
        let joinQuery = placeQuery.outerJoin(with: imageQuery, on: { ($0.reporterID, $1.ownerID) })
       
        let fetchPlaceInfo = self.sqliteService
            .run{ try $0.loadOne(joinQuery, mapping: CursorIterator.makePlaceInfoAndThumbnail) }
        
        let appendCategoryTagsOrNot: ((PlaceInfo, ImageSource?)?) -> Maybe<Place?> = { [weak self] pair in
            guard let self = self else { return .empty() }
            guard let pair = pair else { return .just(nil) }
            let tagsQuery = tags.selectAll{ $0.keyword.in(pair.0.categoryIDs) }
            let fetchTags = self.sqliteService.run { try $0.load(tags, query: tagsQuery) }.catchAndReturn([])
            return fetchTags
                .map{ Place(info: pair.0, thumbnail: pair.1, tags: $0) }
        }
        
        return fetchPlaceInfo
            .flatMap(appendCategoryTagsOrNot)
    }
}


// MARK: - DataModelStorageImpl + Migration

extension DataModelStorageImple {
    
    private func migrationPlan(for version: Int) -> Maybe<Int32> {
        
        let requireVersion = Int32(version)
        let migrationSteps: (Int32, DataBase) throws -> Void = { _, _ in }
        return self.sqliteService.migrate(upto: requireVersion, steps: migrationSteps)
    }
}


private extension CursorIterator {
    
    static func makePlaceInfoAndThumbnail(_ cursor: CursorIterator) throws -> (PlaceInfoTable.Entity, ImageSource?) {
        let placeInfo = try PlaceInfoTable.Entity(cursor)
        let thumbnail = try? ImageSource(cursor)
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

extension Member: RowValueType {
    
    public init(_ cursor: CursorIterator) throws {
        let uid: String = try cursor.next().unwrap()
        let nickName: String = try cursor.next().unwrap()
        let intro: String? = cursor.next()
        let image: ImageSource? = try? ImageSource(cursor)
        var member = Member(uid: uid, nickName: nickName, icon: image)
        member.introduction = intro
        self = member
    }
    
    func asEntity() -> MemberTable.Entity {
        return .init(self.uid, nickName: self.nickName, intro: self.introduction)
    }
    
    func iconEntity() -> ImageSourceTable.Entity? {
        
        let ownerID = self.uid
        return self.icon.map{ ImageSourceTable.Entity(ownerID, source: $0) }
    }
}

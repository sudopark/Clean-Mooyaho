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
    
    func save(member: Member) -> Maybe<Void>
    
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
        let members = MemberTable.self
        let memberQuery = members.selectAll{ $0.uid == memberID }
        
        let images = ImageSourceTable.self
        let imageQuery = images.selectSome{ [$0.sourcetype, $0.path, $0.description, $0.emoji] }
        
        let joinQuery = memberQuery.outerJoin(with: imageQuery, on: { ($0.uid, $1.ownerID) })
        let fetchedMembers: Maybe<[Member]> = self.sqliteService.run(execute: { try $0.load(joinQuery) })
        
        return fetchedMembers.map{ $0.first }
    }
    
    public func save(member: Member) -> Maybe<Void> {
        
        let images = ImageSourceTable.self
        let iconEntity = ImageSourceTable.Entity(member.uid, source: member.icon)
        
        let memberTable = MemberTable.self
        let memberEntity = MemberTable.Entity(member.uid, nickName: member.nickName, intro: member.introduction)
        
        let insertMember = self.sqliteService
            .run{ try $0.insertOne(memberTable, entity: memberEntity, shouldReplace: true) }
        
        let thenUpdateIcon: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.run{ try $0.insertOne(images, entity: iconEntity, shouldReplace: true) }
                .catchAndReturn(())
        }
        
        return insertMember
            .flatMap(thenUpdateIcon)
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
        
        typealias PlaceInfo = PlaceInfoTable.DataModel
        
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
    
    static func makePlaceInfoAndThumbnail(_ cursor: CursorIterator) throws -> (PlaceInfoTable.DataModel, ImageSource?) {
        let placeInfo = try PlaceInfoTable.DataModel(cursor)
        let thumbnail = try? ImageSource(cursor)
        return (placeInfo, thumbnail)
    }
}

private extension Place {
    
    init?(info: PlaceInfoTable.DataModel, thumbnail: ImageSource?, tags: [Tag]) {
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
}

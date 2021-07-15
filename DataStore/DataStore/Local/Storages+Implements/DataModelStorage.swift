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
        
        let joinQuery = memberQuery.innerJoin(with: imageQuery, on: { ($0.uid, $1.ownerID) })
        let fetchedMembers: Maybe<[Member]> = self.sqliteService.run(execute: { try $0.load(joinQuery) })
        
        return fetchedMembers.map{ $0.first }
    }
    
    public func save(member: Member) -> Maybe<Void> {
        
        let images = ImageSourceTable.self
        let iconModel = ImageSourceTable.DataModel(member.uid, source: member.icon)
        
        let members = MemberTable.self
        let memberPropertyModel = MemberTable.DataModel(member.uid, nickName: member.nickName, intro: member.introduction)
        
        let insertMember = self.sqliteService
            .run{ try $0.insertOne(members, model: memberPropertyModel, shouldReplace: true) }
        
        let thenUpdateIcon: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            return self.sqliteService.run{ try $0.insertOne(images, model: iconModel, shouldReplace: true) }
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


// MARK: - DataModelStorageImpl + Migration

extension DataModelStorageImple {
    
    private func migrationPlan(for version: Int) -> Maybe<Int32> {
        
        let requireVersion = Int32(version)
        let migrationSteps: (Int32, DataBase) throws -> Void = { _, _ in }
        return self.sqliteStorage.migrate(upto: requireVersion, steps: migrationSteps)
    }
}

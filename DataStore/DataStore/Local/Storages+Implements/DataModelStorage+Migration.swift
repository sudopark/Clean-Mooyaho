//
//  DataModelStorage+Migration.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SQLiteService

import Domain


// MARK: - DataModelStorageImpl + Migration

extension DataModelStorageImple {
    
    func migrationPlan(for version: Int) -> Maybe<Int32> {
        
        let requireVersion = Int32(version)
        let migrationSteps: (Int32, DataBase) throws -> Void = { _, _ in }
        
        let createTablesAfterMigrationFinished: (Int32, DataBase) -> Void = { [weak self] _, database in
            self?.createTables(database)
        }
        return self.sqliteService.rx
            .migrate(upto: requireVersion,
                     steps: migrationSteps,
                     finalized: createTablesAfterMigrationFinished)
    }
    
    private func createTables(_ database: DataBase) {
        
        do {
            try database.createTableOrNot(MemberTable.self)
            logger.print(level: .debug, "sqlite MemberTable are created..")
        } catch {
            logger.print(level: .error, "fail to create MemberTable")
        }
        
        do {
            try database.createTableOrNot(ImageSourceTable.self)
            logger.print(level: .debug, "sqlite ImageSourceTable are created..")
        } catch {
            logger.print(level: .error, "fail to create ImageSourceTable")
        }
        
        do {
            try database.createTableOrNot(ThumbnailTable.self)
            logger.print(level: .debug, "sqlite ThumbnailTable are created..")
        } catch {
            logger.print(level: .error, "fail to create ThumbnailTable")
        }
        
        do {
            try database.createTableOrNot(ReadCollectionTable.self)
            logger.print(level: .debug, "sqlite ReadCollectionTable are created..")
        } catch {
            logger.print(level: .error, "fail to create ReadCollectionTable")
        }
        
        do {
            try database.createTableOrNot(ReadLinkTable.self)
            logger.print(level: .debug, "sqlite ReadLinkTable are created..")
        } catch {
            logger.print(level: .error, "fail to create ReadLinkTable")
        }
        
        do {
            try database.createTableOrNot(ItemCategoriesTable.self)
            logger.print(level: .debug, "sqlite ItemCategoriesTable are created..")
        } catch {
            logger.print(level: .error, "fail to create ItemCategoriesTable")
        }
    }
}

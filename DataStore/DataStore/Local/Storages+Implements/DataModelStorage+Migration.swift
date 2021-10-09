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
        
        try? database.createTableOrNot(MemberTable.self)
        try? database.createTableOrNot(ImageSourceTable.self)
        try? database.createTableOrNot(ThumbnailTable.self)
        try? database.createTableOrNot(ItemCategoriesTable.self)
        
        logger.print(level: .debug, "sqlite tables are created..")
    }
}

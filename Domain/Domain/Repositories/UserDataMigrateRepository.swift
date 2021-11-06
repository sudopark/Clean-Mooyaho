//
//  UserDataMigrate.swift
//  Domain
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol UserDataMigrateRepository {
    
    func checkMigrationNeed() -> Maybe<Bool>
    
    func requestMoveReadItemCategories(for userID: String) -> Observable<[ItemCategory]>
    
    func requestMoveReadItems(for userID: String) -> Observable<[ReadItem]>
    
    func requestMoveReadLinkMemos(for userID: String) -> Observable<[ReadLinkMemo]>
    
    func clearMigrationNeedData() -> Maybe<Void>
}

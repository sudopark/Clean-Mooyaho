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
    
    func requestMoveReadItemCategories(for userID: String) -> Infallible<[ItemCategory]>
    
    func requestMoveReadItems(for userID: String) -> Infallible<[ReadItem]>
    
    func requestMoveReadLinkMemos(for userID: String) -> Infallible<[ReadLinkMemo]>
    
    func copyMemberCache() -> Infallible<Void>
    
    func clearMigrationNeedData() -> Maybe<Void>
}

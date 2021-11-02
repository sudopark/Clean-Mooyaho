//
//  DataModelStorageGateway.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - DataModelStorageGateWay

public protocol DataModelStorageGateway: AnyObject {
    
    func openAnonymousStorage() -> Maybe<Void>
    
    func closeAnonymousStorage() -> Maybe<Void>
    
    func openUserStorage(_ userID: String) -> Maybe<Void>
    
    func closeUserStorage() -> Maybe<Void>
    
    var curentStorage: DataModelStorage? { get }
}


extension DataModelStorageGateway {
    
    public func switchToAnonymousStorage() -> Maybe<Void> {
        
        let thenOpenAnonymousStorage: () -> Maybe<Void> = { [weak self] in
            return self?.openAnonymousStorage() ?? .empty()
        }
        
        return self.closeUserStorage()
            .flatMap(thenOpenAnonymousStorage)
    }
    
    public func switToUserStorage(_ userID: String) -> Maybe<Void> {
        
        let thenOpenUserStorage: () -> Maybe<Void> = { [weak self] in
            return self?.openUserStorage(userID) ?? .empty()
        }
        
        return self.closeAnonymousStorage()
            .flatMap(thenOpenUserStorage)
    }
}


// MARK: - DataModelStorageGateWayImple

public final class DataModelStorageGatewayImple: DataModelStorageGateway {
    
    private let makeAnonymousStorage: () -> DataModelStorage
    private let makeUserStorage: (String) -> DataModelStorage
    
    public init(makeAnonymousStorage: @escaping () -> DataModelStorage,
                makeUserStorage: @escaping (String) -> DataModelStorage) {
        self.makeAnonymousStorage = makeAnonymousStorage
        self.makeUserStorage = makeUserStorage
    }
    
    private var anonymousStorage: DataModelStorage!
    private var userStorage: DataModelStorage!
    
    private var currentSelectedUserID: String?
    
    public var curentStorage: DataModelStorage? {
        return self.currentSelectedUserID != nil ? self.userStorage : self.anonymousStorage
    }
}


extension DataModelStorageGatewayImple {
    
    private func makeAnonymousStorageIfNeed() -> DataModelStorage {
        if self.anonymousStorage == nil {
            self.anonymousStorage = self.makeAnonymousStorage()
        }
        return self.anonymousStorage
    }
    
    public func openAnonymousStorage() -> Maybe<Void> {
        let storage = self.makeAnonymousStorageIfNeed()
        return storage.openDatabase()
    }
    
    public func closeAnonymousStorage() -> Maybe<Void> {
        guard let storage = self.anonymousStorage else { return .just() }
        return storage.closeDatabase()
            .catchAndReturn(())
    }
    
    private func makeUserStorageIfNeed(_ userID: String) -> DataModelStorage {
        if self.userStorage == nil {
            self.userStorage = self.makeUserStorage(userID)
        }
        return self.userStorage
    }
    
    public func openUserStorage(_ userID: String) -> Maybe<Void> {
        let storage = self.makeUserStorageIfNeed(userID)
        return storage.openDatabase()
    }
    
    public func closeUserStorage() -> Maybe<Void> {
        guard let storage = self.userStorage else { return .just() }
        return storage.closeDatabase()
            .catchAndReturn(())
    }
}

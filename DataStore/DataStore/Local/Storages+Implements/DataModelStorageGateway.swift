//
//  DataModelStorageGateway.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain


// MARK: - DataModelStorageGateWay

public protocol DataModelStorageGateway: AnyObject {
    
    func openAnonymousStorage() -> Maybe<Void>
    
    func openedAnonymousStorage() -> Maybe<DataModelStorage>
    
    func closeAnonymousStorage() -> Maybe<Void>
    
    func openUserStorage(_ userID: String) -> Maybe<Void>
    
    func closeUserStorage() -> Maybe<Void>
    
    var curentStorage: DataModelStorage? { get }
    
    func checkHasAnonymousStorage() -> Bool
    
    func removeAnonymousStorage()
    
    func removeUserStorage()
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
    
    private let anonymousStoragePath: String
    private let makeAnonymousStorage: () -> DataModelStorage
    private let makeUserStorage: (String) -> DataModelStorage
    
    public init(anonymousStoragePath: String,
                makeAnonymousStorage: @escaping () -> DataModelStorage,
                makeUserStorage: @escaping (String) -> DataModelStorage) {
        self.anonymousStoragePath = anonymousStoragePath
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
        return self.openedAnonymousStorage()
            .map { _ in }
    }
    
    public func openedAnonymousStorage() -> Maybe<DataModelStorage> {
        logger.print(level: .info, "request open anonymous storage")
        let storage = self.makeAnonymousStorageIfNeed()
        return storage.openDatabase()
            .map { storage }
    }
    
    public func closeAnonymousStorage() -> Maybe<Void> {
        logger.print(level: .info, "close anonymous storage")
        guard let storage = self.anonymousStorage else { return .just() }
        
        let thenClearUserStorage: () -> Void = { [weak self] in
            self?.anonymousStorage = nil
        }
        return storage.closeDatabase()
            .catchAndReturn(())
            .do(afterNext: thenClearUserStorage)
    }
    
    private func makeUserStorageIfNeed(_ userID: String) -> DataModelStorage {
        if self.userStorage == nil {
            self.userStorage = self.makeUserStorage(userID)
        }
        self.currentSelectedUserID = userID
        return self.userStorage
    }
    
    public func openUserStorage(_ userID: String) -> Maybe<Void> {
        let secureMessage = SecureLoggingMessage()
            |> \.fullText .~ "request open user storage: %@"
            |> \.secureField .~ [userID]
        logger.print(level: .info, secureMessage)
        let storage = self.makeUserStorageIfNeed(userID)
        return storage.openDatabase()
    }
    
    public func closeUserStorage() -> Maybe<Void> {
        logger.print(level: .info, "close user storage")
        self.currentSelectedUserID = nil
        guard let storage = self.userStorage else { return .just() }
        
        let thenClearUserStorage: () -> Void = { [weak self] in
            self?.userStorage = nil
        }
        return storage.closeDatabase()
            .catchAndReturn(())
            .do(afterNext: thenClearUserStorage)
    }
    
    public func checkHasAnonymousStorage() -> Bool {
        return FileManager.default.fileExists(atPath: self.anonymousStoragePath)
    }
    
    public func removeAnonymousStorage() {
        let path = self.anonymousStoragePath
        try? FileManager.default.removeItem(atPath: path)
        self.anonymousStorage = nil
    }
    
    public func removeUserStorage() {
        guard let userDBPath = self.userStorage?.dbPath else { return }
        try? FileManager.default.removeItem(atPath: userDBPath)
        self.userStorage = nil
    }
}

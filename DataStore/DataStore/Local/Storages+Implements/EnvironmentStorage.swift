//
//  EnvironmentStorage.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


// MARK: - EnvironmentStorage

public enum EnvironmentDataScope {
    case perUser
    case perDevice
}

public protocol EnvironmentStorage: Sendable {
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool?>
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void>
    
    func fetchLatestReadItemSortOrder() -> Maybe<ReadCollectionItemSortOrder?>
    
    func updateLatestReadItemSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?>
    
    func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
    
    func fetchRaedingLinkIDs() -> [String]
    
    func replaceReadiingLinkIDs(_ values: [String])
    
    func fetchReloadNeedCollectionIDs() -> [String]
    
    func updateIsReloadNeedCollectionIDs(_ newValue: [String])
    
    func isAddItemGuideEverShown() -> Bool
    
    func markAsAddItemGuideShown()
    
    func didWelComeItemAdded() -> Bool
    
    func updateDidWelcomeItemAdded()
    
    func updateEnableLastReadPositionSaveOption(_ isOn: Bool)
    
    func isEnabledLastReadPositionSaveOption() -> Bool
    
    func clearAll(scope: EnvironmentDataScope)
}

var environmentStorageKeyPrefix: String?

// MARK: - EnvironmentStorageKeys

enum EnvironmentStorageKeys: @unchecked Sendable {
    
    case pendingPlaceInfo(_ memberID: String)
    case readItemIsShrinkMode
    case readItemLatestSortOrder
    case readitemCustomOrder(_ collectionID: String)
    case readingLinkIDs
    case reloadNeedCollectionIDs
    case addItemGuideEverShown
    case welcomeItemAdded
    case saveLastReadPosition
    
    var keyvalue: String {
        let prefix = environmentStorageKeyPrefix
        switch self {
        case let .pendingPlaceInfo(memberID):
            return "pendingPlaceInfo:\(memberID)".insertPrefixOrNot(prefix)
            
        case .readItemIsShrinkMode:
            return "readItemIsShrinkMode".insertPrefixOrNot(prefix)
            
        case .readItemLatestSortOrder:
            return "readItemLatestSortOrder"
            
        case let .readitemCustomOrder(collectionID):
            return "readitemCustomOrder:\(collectionID)".insertPrefixOrNot(prefix)
            
        case .readingLinkIDs:
            return "readingLinkIDs".insertPrefixOrNot(prefix)
            
        case .reloadNeedCollectionIDs:
            return "reloadNeedCollectionIDs".insertPrefixOrNot(prefix)
            
        case .addItemGuideEverShown:
            return "addItemGuideEverShown".insertPrefixOrNot(prefix)
            
        case .welcomeItemAdded:
            return "welcomeItemAdded:".insertPrefixOrNot(prefix)
            
        case .saveLastReadPosition:
            return "saveLastReadPosition".insertPrefixOrNot(prefix)
        }
    }
    
    var scope: EnvironmentDataScope {
        switch self {
        case .addItemGuideEverShown, .welcomeItemAdded: return .perDevice
        default: return .perUser
        }
    }
    
    fileprivate static func keyPrefixes(for scope: EnvironmentDataScope) -> [String] {
        let prefix = environmentStorageKeyPrefix
        switch scope {
        case .perUser:
            return [
                "pendingPlaceInfo".insertPrefixOrNot(prefix),
                "readItemIsShrinkMode".insertPrefixOrNot(prefix),
                "readItemLatestSortOrder".insertPrefixOrNot(prefix),
                "readitemCustomOrder".insertPrefixOrNot(prefix),
                "readingLinkIDs".insertPrefixOrNot(prefix),
                "reloadNeedCollectionIDs".insertPrefixOrNot(prefix),
                "saveLastReadPosition".insertPrefixOrNot(prefix)
            ]
        case .perDevice:
            return [
                "addItemGuideEverShown".insertPrefixOrNot(prefix),
                "welcomeItemAdded".insertPrefixOrNot(prefix)
            ]
        }
    }
}

extension UserDefaults: @unchecked Sendable { }

extension UserDefaults: EnvironmentStorage {
    
    func get<T: Decodable>(_ key: String) -> Result<T?, Error> {
        do {
            let model = try self.string(forKey: key)
                .flatMap{ $0.data(using: .utf8) }
                .flatMap {
                    try JSONDecoder().decode(T.self, from: $0)
                }
            return .success(model)
        } catch let error {
            return .failure(error)
        }
    }
    
    private func load<T: Decodable>(_ key: String) -> Maybe<T?> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            let result: Result<T?, Error> = self.get(key)
            switch result {
            case let .success(model):
                callback(.success(model))
            case let .failure(error):
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    private func write<T: Encodable>(_ key: String, value: T) -> Result<Void, Error> {
        do {
            
            let data = try JSONEncoder().encode(value)
            guard let stringValue = String(data: data, encoding: .utf8) else {
                throw LocalErrors.invalidData("save \(String(describing: T.self))")
            }
            self.setValue(stringValue, forKey: key)
            return .success(())
            
        } catch let error {
            return .failure(error)
        }
    }
    
    private func save<T: Encodable>(_ key: String, value: T) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            let result = self.write(key, value: value)
            switch result {
            case .success:
                callback(.success(()))
            case let .failure(error):
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    private func remove(_ key: String) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            self.runRemove(key)
            callback(.success(()))
            return Disposables.create()
        }
    }
    
    private func runRemove(_ key: String) {
        self.removeObject(forKey: key)
    }
}


// MARK: - UserDefaults + PendingNewPlace

extension UserDefaults {
    
    public func clearAll(scope: EnvironmentDataScope) {
        let storedDataKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let keyPrefixes = EnvironmentStorageKeys.keyPrefixes(for: scope)
        let shouldRemoveTargetKeys = storedDataKeys.filter { key in
            return keyPrefixes.first(where: { key.starts(with: $0) }) != nil
        }
        shouldRemoveTargetKeys.forEach {
            self.runRemove($0)
        }
    }
    
    public func fetchReadItemIsShrinkMode() -> Maybe<Bool?> {
        let key = EnvironmentStorageKeys.readItemIsShrinkMode
        return self.load(key.keyvalue)
    }
    
    public func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void> {
        let key = EnvironmentStorageKeys.readItemIsShrinkMode
        return self.save(key.keyvalue, value: newValue)
    }
    
    public func fetchLatestReadItemSortOrder() -> Maybe<ReadCollectionItemSortOrder?> {
        let key = EnvironmentStorageKeys.readItemLatestSortOrder
        return self.load(key.keyvalue)
    }
    
    public func updateLatestReadItemSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void> {
        let key = EnvironmentStorageKeys.readItemLatestSortOrder
        return self.save(key.keyvalue, value: newValue)
    }
    
    public func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        let key = EnvironmentStorageKeys.readitemCustomOrder(collectionID)
        return self.load(key.keyvalue)
    }
    
    public func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void> {
        let key = EnvironmentStorageKeys.readitemCustomOrder(collectionID)
        return self.save(key.keyvalue, value: itemIDs)
    }
    
    public func fetchRaedingLinkIDs() -> [String] {
        let key = EnvironmentStorageKeys.readingLinkIDs
        let ids: Result<[String]?, Error> = self.get(key.keyvalue)
        return (try? ids.get()) ?? []
    }
    
    public func replaceReadiingLinkIDs(_ values: [String]) {
        let key = EnvironmentStorageKeys.readingLinkIDs
        _ = self.write(key.keyvalue, value: values)
    }
    
    public func fetchReloadNeedCollectionIDs() -> [String] {
        let key = EnvironmentStorageKeys.reloadNeedCollectionIDs
        let ids: Result<[String]?, Error> = self.get(key.keyvalue)
        return (try? ids.get()) ?? []
    }
    
    public func updateIsReloadNeedCollectionIDs(_ newValue: [String]) {
        let key = EnvironmentStorageKeys.reloadNeedCollectionIDs
        _ = self.write(key.keyvalue, value: newValue)
    }
    
    public func isAddItemGuideEverShown() -> Bool {
        let key = EnvironmentStorageKeys.addItemGuideEverShown
        return self.bool(forKey: key.keyvalue)
    }
    
    public func markAsAddItemGuideShown() {
        let key = EnvironmentStorageKeys.addItemGuideEverShown
        self.set(true, forKey: key.keyvalue)
    }
    
    public func didWelComeItemAdded() -> Bool {
        let key = EnvironmentStorageKeys.welcomeItemAdded
        return self.bool(forKey: key.keyvalue)
    }
    
    public func updateDidWelcomeItemAdded() {
        let key = EnvironmentStorageKeys.welcomeItemAdded
        self.set(true, forKey: key.keyvalue)
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) {
        let key = EnvironmentStorageKeys.saveLastReadPosition
        self.set(isOn, forKey: key.keyvalue)
    }
    
    public func isEnabledLastReadPositionSaveOption() -> Bool {
        let key = EnvironmentStorageKeys.saveLastReadPosition
        return self.value(forKey: key.keyvalue) as? Bool ?? true
    }
}



// mapping

extension ImageSource: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case path
        case width
        case height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let path: String = try container.decode(String.self, forKey: .path)
        if let width = try? container.decode(Double.self, forKey: .width),
           let height = try? container.decode(Double.self, forKey: .height) {
            self.init(path: path, size: .init(width, height))
        } else {
            self.init(path: path, size: nil)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.path, forKey: .path)
        try container.encode(self.size?.width, forKey: .width)
        try container.encode(self.size?.height, forKey: .height)
    }
}

extension ReadCollectionItemSortOrder: Codable {
    
    private var isAscendingOrder: Bool? {
        switch self {
        case let .byCreatedAt(isAscending),
             let .byLastUpdatedAt(isAscending),
             let .byPriority(isAscending): return isAscending
        default: return nil
        }
    }
    
    private var caseName: String {
        switch self {
        case .byCreatedAt: return "created"
        case .byLastUpdatedAt: return "last updated"
        case .byPriority: return "priority"
        case .byCustomOrder: return "custom"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case caseName
        case isAscending
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseName: String = try container.decode(String.self, forKey: .caseName)
        let isAscending: Bool? = try? container.decode(Bool.self, forKey: .isAscending)
        switch (caseName, isAscending) {
        case ("created", let .some(flag)): self = .byPriority(flag)
        case ("last updated", let .some(flag)): self = .byLastUpdatedAt(flag)
        case ("priority", let .some(flag)): self = .byPriority(flag)
        case ("custom", _): self = .byCustomOrder
        default: throw LocalErrors.deserializeFail("ReadCollectionItemSortOrder")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.caseName, forKey: .caseName)
        try? container.encode(self.isAscendingOrder, forKey: .isAscending)
    }
}


private extension String {
    
    func insertPrefixOrNot(_ prefix: String?) -> String {
        return prefix.map{ "\($0)_\(self)" } ?? self
    }
}

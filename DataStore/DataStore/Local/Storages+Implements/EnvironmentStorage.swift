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

public protocol EnvironmentStorage {
    
    func savePendingNewPlaceForm(_ form: NewPlaceForm) -> Maybe<Void>

    func fetchPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?>

    func removePendingNewPlaceForm(_ memberID: String) -> Maybe<Void>
    
    func fetchReadItemIsShrinkMode() -> Maybe<Bool?>
    
    func updateReadItemIsShrinkMode(_ newValue: Bool) -> Maybe<Void>
    
    func fetchLatestReadItemSortOrder() -> Maybe<ReadCollectionItemSortOrder?>
    
    func updateLatestReadItemSortOrder(to newValue: ReadCollectionItemSortOrder) -> Maybe<Void>
    
    func fetchReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?>
    
    func updateReadItemCustomOrder(for collectionID: String, itemIDs: [String]) -> Maybe<Void>
    
    func fetchRaedingLinkIDs() -> [String]
    
    func replaceReadiingLinkIDs(_ values: [String])
    
    func fetchIsReloadCollectionsNeed() -> Bool
    
    func updateIsReloadCollectionNeed(_ newValue: Bool)
    
    func isAddItemGuideEverShown() -> Bool
    
    func markAsAddItemGuideShown()
    
    func clearAll()
}

var environmentStorageKeyPrefix: String?

// MARK: - EnvironmentStorageKeys

enum EnvironmentStorageKeys {
    
    case pendingPlaceInfo(_ memberID: String)
    case readItemIsShrinkMode
    case readItemLatestSortOrder
    case readitemCustomOrder(_ collectionID: String)
    case readingLinkIDs
    case isReloadNeed
    case addItemGuideEverShown
    
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
            
        case .isReloadNeed:
            return "isReloadNeed".insertPrefixOrNot(prefix)
            
        case .addItemGuideEverShown:
            return "addItemGuideEverShown".insertPrefixOrNot(prefix)
        }
    }
    
    fileprivate static func keyPrefixes() -> [String] {
        let prefix = environmentStorageKeyPrefix
        return [
            "pendingPlaceInfo".insertPrefixOrNot(prefix),
            "readItemIsShrinkMode".insertPrefixOrNot(prefix),
            "readItemLatestSortOrder".insertPrefixOrNot(prefix),
            "readitemCustomOrder".insertPrefixOrNot(prefix),
            "readingLinkIDs".insertPrefixOrNot(prefix),
            "isReloadNeed".insertPrefixOrNot(prefix),
            "addItemGuideEverShown".insertPrefixOrNot(prefix)
        ]
    }
}


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
    
    public func clearAll() {
        let storedDataKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let keyPrefixes = EnvironmentStorageKeys.keyPrefixes()
        let shouldRemoveTargetKeys = storedDataKeys.filter { key in
            return keyPrefixes.first(where: { key.starts(with: $0) }) != nil
        }
        shouldRemoveTargetKeys.forEach {
            self.runRemove($0)
        }
    }
    
    public func savePendingNewPlaceForm(_ form: NewPlaceForm) -> Maybe<Void> {
        
        let key = EnvironmentStorageKeys.pendingPlaceInfo(form.reporterID)
        let pendingInfo = PendingNewPlaceForm(form: form)
        return self.save(key.keyvalue, value: pendingInfo)
    }

    public func fetchPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?> {
        let key = EnvironmentStorageKeys.pendingPlaceInfo(memberID)
        let pendingInfo: Maybe<PendingNewPlaceForm?> = self.load(key.keyvalue)
        
        let mapping: (PendingNewPlaceForm?) -> PendingRegisterNewPlaceForm? = { pending in
            return pending.map { value in
                return PendingRegisterNewPlaceForm(form: value.form,
                                                   time: Date(timeIntervalSince1970: value.time))
            }
        }
        
        return pendingInfo
            .map(mapping)
    }

    public func removePendingNewPlaceForm(_ memberID: String) -> Maybe<Void> {
        let key = EnvironmentStorageKeys.pendingPlaceInfo(memberID)
        return self.remove(key.keyvalue)
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
    
    public func fetchIsReloadCollectionsNeed() -> Bool {
        let key = EnvironmentStorageKeys.isReloadNeed
        return self.bool(forKey: key.keyvalue)
    }
    
    public func updateIsReloadCollectionNeed(_ newValue: Bool) {
        let key = EnvironmentStorageKeys.isReloadNeed
        self.set(newValue, forKey: key.keyvalue)
    }
    
    public func isAddItemGuideEverShown() -> Bool {
        let key = EnvironmentStorageKeys.addItemGuideEverShown
        return self.bool(forKey: key.keyvalue)
    }
    
    public func markAsAddItemGuideShown() {
        let key = EnvironmentStorageKeys.addItemGuideEverShown
        self.set(true, forKey: key.keyvalue)
    }
}



// mapping

extension PlaceCategoryTag: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case keyword
        case emoji
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue: String = try container.decode(String.self, forKey: .type)
        guard let type = TagType(rawValue: rawValue) else {
            throw LocalErrors.deserializeFail("PlaceCategoryTag")
        }
        self.init(type: type,
                  keyword: try container.decode(String.self, forKey: .keyword),
                  emoji: try? container.decode(String.self, forKey: .emoji))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.tagType.rawValue, forKey: .type)
        try container.encode(self.keyword, forKey: .keyword)
        try container.encode(self.emoji, forKey: .emoji)
    }
}

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

extension NewPlaceForm: Codable {
    
    private enum CodingKeys: String, CodingKey {
        
        case reporterID = "reporter_id"
        case provider = "info_provider"
        case title
        case thumbnail
        case searchID = "search_id"
        case link
        case latt
        case lng
        case address
        case contact
        case categoies
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reporterID: String = try container.decode(String.self, forKey: .reporterID)
        let rawValue: String = try container.decode(String.self, forKey: .provider)
        guard let provider = Place.RequireInfoProvider(rawValue: rawValue) else {
            throw LocalErrors.deserializeFail("NewPlaceForm")
        }
        self.init(reporterID: reporterID, infoProvider: provider)
        self.title = try container.decode(String.self, forKey: .title)
        self.thumbnail = try? container.decode(ImageSource.self, forKey: .thumbnail)
        self.searchID = try? container.decode(String.self, forKey: .searchID)
        self.detailLink = try? container.decode(String.self, forKey: .link)
        self.coordinate = .init(latt: try container.decode(Double.self, forKey: .latt),
                                long: try container.decode(Double.self, forKey: .lng))
        self.address = try container.decode(String.self, forKey: .address)
        self.contact = try? container.decode(String.self, forKey: .contact)
        self.categoryTags = (try? container.decode([PlaceCategoryTag].self, forKey: .categoies)) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.reporterID, forKey: .reporterID)
        try container.encode(self.infoProvider.rawValue, forKey: .provider)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.thumbnail, forKey: .thumbnail)
        try container.encode(self.searchID, forKey: .searchID)
        try container.encode(self.detailLink, forKey: .link)
        try container.encode(self.coordinate.latt, forKey: .latt)
        try container.encode(self.coordinate.long, forKey: .lng)
        try container.encode(self.address, forKey: .address)
        try container.encode(self.contact, forKey: .contact)
        try container.encode(self.categoryTags, forKey: .categoies)
    }
}


fileprivate struct PendingNewPlaceForm: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case time
        case form
    }
    
    let time: Double
    let form: NewPlaceForm
    
    init(form: NewPlaceForm) {
        self.time = .now()
        self.form = form
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = try container.decode(Double.self, forKey: .time)
        self.form = try container.decode(NewPlaceForm.self, forKey: .form)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.form, forKey: .form)
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

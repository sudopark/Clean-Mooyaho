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
}

// MARK: - EnvironmentStorageKeys

enum EnvironmentStorageKeys {
    
    case pendingPlaceInfo(_ memberID: String)
    
    var keyvalue: String {
        switch self {
        case let .pendingPlaceInfo(memberID):
            return "pendingPlaceInfo:\(memberID)"
        }
    }
}


extension UserDefaults: EnvironmentStorage {
    
    
    func load<T: Decodable>(_ key: String) -> Maybe<T?> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            do {
                let model = try self.string(forKey: key)
                    .flatMap{ $0.data(using: .utf8) }
                    .flatMap {
                        try JSONDecoder().decode(T.self, from: $0)
                    }
                callback(.success(model))
            } catch let error {
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func save<T: Encodable>(_ key: String, value: T) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            do {
                
                let data = try JSONEncoder().encode(value)
                guard let stringValue = String(data: data, encoding: .utf8) else {
                    throw LocalErrors.invalidData("save \(String(describing: T.self))")
                }
                self.setValue(stringValue, forKey: key)
                callback(.success(()))
                
            } catch let error {
                callback(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func remove(_ key: String) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            self.removeObject(forKey: key)
            callback(.success(()))
            return Disposables.create()
        }
    }
}


// MARK: - UserDefaults + PendingNewPlace

extension UserDefaults {
    
    
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

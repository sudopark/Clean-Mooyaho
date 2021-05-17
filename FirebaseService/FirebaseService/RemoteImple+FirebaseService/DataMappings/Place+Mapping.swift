//
//  Place+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/09.
//

import Foundation

import Domain
import DataStore


// MARK: - map user location

enum UserLocMappingKey: String, JSONMappingKeys {
    case latt
    case long
    case timeStamp = "ts"
}

extension UserLocation: DocumentMappable {
    
    typealias Key = UserLocMappingKey
    
    init?(docuID: String, json: JSON) {
        guard let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let timeStamp = json[Key.timeStamp] as? Double else {
            return nil
        }
        let location = LastLocation(lattitude: latt, longitude: long, timeStamp: timeStamp)
        self.init(userID: docuID, lastLocation: location)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.latt.rawValue: self.lastLocation.lattitude,
            Key.long.rawValue: self.lastLocation.longitude,
            Key.timeStamp.rawValue: self.lastLocation.timeStamp
        ]
        return (self.userID, json)
    }
}


// MARK: - decode and map place and place search data

extension SearchingPlace: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case uid = "id"
        case title = "name"
        case latt = "x"
        case long = "y"
        case contact = "tel"
        case categories = "category"
        case address = "address"
        case roadAddress
        case thumbnail = "thumUrl"
        case link = "homePage"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uid = try container.decode(String.self, forKey: .uid)
        let title = try container.decode(String.self, forKey: .title)
        guard let latt = try container.decode(String.self, forKey: .latt).asDouble(),
              let long = try container.decode(String.self, forKey: .long).asDouble() else {
            throw RemoteErrors.mappingFail("SearchingPlace - coordinate")
        }
        let contact = try? container.decode(String.self, forKey: .contact)
        let categories = (try? container.decode([String].self, forKey: .categories)) ?? []
        guard let address = (try? container.decode(String.self, forKey: .roadAddress))
                ?? (try? container.decode(String.self, forKey: .address)) else {
            throw RemoteErrors.mappingFail("SearchingPlace - address")
        }
        let thumbnail = try? container.decode(String.self, forKey: .thumbnail)
        let imageSource = thumbnail.map{ ImageSource.reference($0, description: "naver")}
        let link = try? container.decode(String.self, forKey: .link)
        
        self = .init(uid: uid, title: title,
                     coordinate: .init(latt: latt, long: long),
                     contact: contact,
                     address: address,
                     categories: categories,
                     thumbnail: imageSource,
                     link: link)
    }
}


extension SearchingPlaceCollection: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case result
        case place
        case pageIndex = "page"
        case list
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let resultContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .result)
        let placeContainer = try resultContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .place)
        let pageIndex = try? placeContainer.decode(Int.self, forKey: .pageIndex)
        let list = (try? placeContainer.decode([SearchingPlace].self, forKey: .list)) ?? []
        
        self = .init(query: "", currentPage: pageIndex, places: list, isFinalPage: list.isEmpty)
    }
}

private extension String {
    
    func asDouble() -> Double? {
        return Double(self)
    }
}


// MARK: - map place snippet

enum PlaceMappingKey: String, JSONMappingKeys {
    case title = "tlt"
    case thumbnail = "thumb"
    case extraSearchID = "extr_s_id"
    case detailLink = "link"
    case contact = "contact"
    case latt
    case long
    case address = "addr"
    case reporterID = "reporter_id"
    case infoProvider = "info_provider"
    case categoryTags = "cat_tags"
    case createdAt = "crt_at"
    case pickCount = "pick_cnt"
    case lastPickedAt = "last_pick_at"
    case tagType = "t_type"
    case keyword = "kwd"
}

fileprivate typealias Key = PlaceMappingKey

extension PlaceSnippet: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let title = json[Key.title] as? String else { return nil }
        self.init(placeID: docuID, title: title, latt: latt, long: long)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            Key.latt.rawValue: self.latt,
            Key.long.rawValue: self.long,
            Key.title.rawValue: self.title
        ]
        return (self.placeID, json)
    }
}


// MARK: - map place

extension PlaceCategoryTag: JSONMappable {
    
    init?(json: JSON) {
        guard let typeValue = json[Key.tagType] as? String,
              let type = TagType(rawValue: typeValue),
              let keyword = json[Key.keyword] as? String else {
            return nil
        }
        self.init(type: type, keyword: keyword)
    }
    
    func asJSON() -> JSON {
        return [
            Key.tagType.rawValue: self.tagType.rawValue,
            Key.keyword.rawValue: self.keyword
        ]
    }
}

extension Place: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let title = json[Key.title] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let address = json[Key.address] as? String,
              let reporterID = json[Key.reporterID] as? String,
              let providerValue = json[Key.infoProvider] as? String,
              let provider = RequireInfoProvider(rawValue: providerValue),
              let tagsJsonArray = json[Key.categoryTags] as? [[String: Any]],
              let createdAt = json[Key.createdAt] as? Double,
              let pickCount = json[Key.pickCount] as? Int,
              let lastPickedAt = json[Key.lastPickedAt] as? Double else { return nil }
        
        let tags = tagsJsonArray.compactMap{ PlaceCategoryTag(json: $0) }
        guard tags.isNotEmpty else { return nil }
        
        self.init(uid: docuID,
                  title: title,
                  thumbnail: ImageSource(json: json[Key.thumbnail] as? [String: Any] ?? [:]),
                  externalSearchID: json[Key.extraSearchID] as? String,
                  detailLink: json[Key.detailLink] as? String,
                  coordinate: .init(latt: latt, long: long),
                  address: address,
                  contact: json[Key.contact] as? String,
                  categoryTags: tags,
                  reporterID: reporterID,
                  infoProvider: provider,
                  createdAt: createdAt,
                  pickCount: pickCount,
                  lastPickedAt: lastPickedAt)
    }
    
    func asDocument() -> (String, JSON) {
        
        var json = JSON()
        json[Key.title] = self.title
        json[Key.thumbnail] = self.thumbnail?.asJSON
        json[Key.extraSearchID] = self.externalSearchID
        json[Key.detailLink] = self.detailLink
        json[Key.latt] = self.coordinate.latt
        json[Key.long] = self.coordinate.long
        json[Key.address] = self.address
        json[Key.contact] = self.contact
        json[Key.categoryTags] = self.placeCategoryTags.map{ $0.asJSON() }
        json[Key.reporterID] = self.reporterID
        json[Key.infoProvider] = self.requireInfoProvider.rawValue
        json[Key.createdAt] = self.createdAt
        json[Key.pickCount] = self.placePickCount
        json[Key.lastPickedAt] = self.lastPickedAt
        
        return (self.uid, json)
    }
}


// MARK: - map newPlaceForm

extension NewPlaceForm: JSONMappable {
    
    convenience init?(json: JSON) {
        guard let title = json[Key.title] as? String,
              let latt = json[Key.latt] as? Double,
              let long = json[Key.long] as? Double,
              let address = json[Key.address] as? String,
              let reporterID = json[Key.reporterID] as? String,
              let providerValue = json[Key.infoProvider] as? String,
              let provider = Place.RequireInfoProvider(rawValue: providerValue),
              let tagsJsonArray = json[Key.categoryTags] as? [[String: Any]] else { return nil }
        
        let tags = tagsJsonArray.compactMap{ PlaceCategoryTag(json: $0) }
        guard tags.isNotEmpty else { return nil }
        
        self.init(reporterID: reporterID, infoProvider: provider)
        self.title = title
        self.coordinate = .init(latt: latt, long: long)
        self.address = address
        self.categoryTags = tags
    }
    
    func asJSON() -> JSON {
        var json = JSON()
        json[Key.title] = self.title
        json[Key.thumbnail] = self.thumbnail?.asJSON
        json[Key.extraSearchID] = self.searchID
        json[Key.detailLink] = self.detailLink
        json[Key.latt] = self.coordinate.latt
        json[Key.long] = self.coordinate.long
        json[Key.address] = self.address
        json[Key.contact] = self.contact
        json[Key.categoryTags] = self.categoryTags.map{ $0.asJSON() }
        json[Key.reporterID] = self.reporterID
        json[Key.infoProvider] = self.infoProvider.rawValue
        json[Key.createdAt] = TimeStamp.now
        json[Key.pickCount] = 1
        json[Key.lastPickedAt] = TimeStamp.now
        
        return json
    }
    
}

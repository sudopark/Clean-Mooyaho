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

extension UserLocation: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let latt = json["latt"] as? Double,
              let long = json["long"] as? Double,
              let timeStamp = json["time_stamp"] as? Double else {
            return nil
        }
        let location = LastLocation(lattitude: latt, longitude: long, timeStamp: timeStamp)
        self.init(userID: docuID, lastLocation: location)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            "latt": self.lastLocation.lattitude,
            "long": self.lastLocation.longitude,
            "time_stamp": self.lastLocation.timeStamp
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
        
        self = .init(query: nil, currentPage: pageIndex, places: list)
    }
}

private extension String {
    
    func asDouble() -> Double? {
        return Double(self)
    }
}


// MARK: - map place snippet

extension PlaceSnippet: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let latt = json["latt"] as? Double,
              let long = json["long"] as? Double,
              let title = json["title"] as? String else { return nil }
        self.init(placeID: docuID, title: title, latt: latt, long: long)
    }
    
    func asDocument() -> (String, JSON) {
        let json: JSON = [
            "latt": self.latt,
            "long": self.long,
            "title": self.title
        ]
        return (self.placeID, json)
    }
}


// MARK: - map place

extension PlaceCategoryTag: JSONMappable {
    
    init?(json: JSON) {
        guard let type = json["type"] as? String,
              let creatorID = json["creator_id"] as? String,
              let keyword = json["keyword"] as? String else {
            return nil
        }
        self.init(type: type, creatorID: creatorID, keyword: keyword)
    }
    
    func asJSON() -> JSON {
        return [
            "type": self.tagType,
            "creator_id": self.creatorID,
            "keyword": self.keyword
        ]
    }
}

extension Place: DocumentMappable {
    
    init?(docuID: String, json: JSON) {
        guard let title = json["title"] as? String,
              let latt = json["latt"] as? Double,
              let long = json["long"] as? Double,
              let address = json["address"] as? String,
              let reporterID = json["reporter_id"] as? String,
              let providerValue = json["info_provider"] as? String,
              let provider = Place.RequireInfoProvider(rawValue: providerValue),
              let tagsJsonArray = json["category_tags"] as? [[String: Any]],
              let createdAt = json["created_at"] as? Double,
              let pickCount = json["pick_count"] as? Int,
              let lastPickedAt = json["last_pick_at"] as? Double else { return nil }
        
        let tags = tagsJsonArray.compactMap{ PlaceCategoryTag(json: $0) }
        guard tags.isNotEmpty else { return nil }
        
        self.init(uid: docuID,
                  title: title,
                  thumbnail: ImageSource(json: json["thumbnail"] as? [String: Any] ?? [:]),
                  externalSearchID: json["ext_search_id"] as? String,
                  detailLink: json["detail_link"] as? String,
                  coordinate: .init(latt: latt, long: long),
                  address: address,
                  contact: json["contact"] as? String,
                  categoryTags: tags,
                  reporterID: reporterID,
                  infoProvider: provider,
                  createdAt: createdAt,
                  pickCount: pickCount,
                  lastPickedAt: lastPickedAt)
    }
    
    func asDocument() -> (String, JSON) {
        
        var json = JSON()
        json["title"] = self.title
        json["thumbnail"] = self.thumbnail?.asJSON
        json["ext_search_id"] = self.externalSearchID
        json["detail_link"] = self.detailLink
        json["latt"] = self.coordinate.latt
        json["long"] = self.coordinate.long
        json["address"] = self.address
        json["contact"] = self.contact
        json["category_tags"] = self.placeCategoryTags.map{ $0.asJSON() }
        json["reporter_id"] = self.reporterID
        json["info_provider"] = self.requireInfoProvider.rawValue
        json["created_at"] = self.createdAt
        json["pick_count"] = self.placePickCount
        json["last_pick_at"] = self.lastPickedAt
        
        return (self.uid, json)
    }
}

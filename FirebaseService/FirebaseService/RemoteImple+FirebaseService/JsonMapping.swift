//
//  DataMapping.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation

import Domain
import DataStore



typealias JSON = [String: Any]

extension JSON {
    
    func childJson(for key: String) -> JSON? {
        return self[key] as? JSON
    }
    
    func string(for key: String) -> String? {
        return self[key] as? String
    }
}

// MARK: - map member


extension DataModels.Icon {
    
    init?(json: JSON) {
        if let pathValue = json["path"] as? String {
            self.init(path: pathValue)
            
        } else if let referenceJson = json["reference"] as? [String: Any],
                  let pathValue = referenceJson["path"] as? String {
            let description = referenceJson["description"] as? String
            self.init(external: pathValue, description: description)
            
        } else {
            return nil
        }
    }
}

extension DataModels.Member {
    
    init(docuID: String, json: JSON) {
        self.init(uid: docuID)
        self.nickName = json.string(for: "nick_name")
        self.icon = json.childJson(for: "icon").flatMap(DataModels.Icon.init(json:))
    }
}


// MARK: - map user location

extension UserLocation {
    
    func asJSON() -> [String: Any] {
        return [
            "latt": self.lastLocation.lattitude,
            "long": self.lastLocation.longitude,
            "timestamp": self.lastLocation.timeStamp
        ]
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

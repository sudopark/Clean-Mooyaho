//
//  SearchingPlace.swift
//  Domain
//
//  Created by sudo.park on 2021/05/08.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct SearchingPlace {
    
    public let uid: String
    public let title: String
    public let coordinate: Coordinate
    public let contact: String?
    public let categories: [String]
    public let address: String
    public let thumbnail: ImageSource?
    public let link: String?
    
    public init(uid: String, title: String,
                coordinate: Coordinate,
                contact: String? = nil, address: String,
                categories: [String],
                thumbnail: ImageSource? = nil, link: String? = nil) {
        self.uid = uid
        self.title = title
        self.coordinate = coordinate
        self.contact = contact
        self.address = address
        self.categories = categories
        self.thumbnail = thumbnail
        self.link = link
    }
}


public struct SearchingPlaceCollection {
    
    public let query: String?
    public let currentPage: Int?
    public let places: [SearchingPlace]
    
    public init(query: String?, currentPage: Int? = nil, places: [SearchingPlace]) {
        self.query = query
        self.currentPage = currentPage
        self.places = places
    }
}
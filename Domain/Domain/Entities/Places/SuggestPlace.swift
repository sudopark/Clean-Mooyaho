//
//  SuggestPlace.swift
//  Domain
//
//  Created by sudo.park on 2021/05/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Place Snippet

public struct PlaceSnippet {
    
    public let placeID: String
    public let title: String
    public let latt: Double
    public let long: Double
    
    public init(placeID: String, title: String, latt: Double, long: Double) {
        self.placeID = placeID
        self.title = title
        self.latt = latt
        self.long = long
    }
    
    public init(place: Place) {
        self.placeID = place.uid
        self.title = place.title
        self.latt = place.coordinate.latt
        self.long = place.coordinate.long
    }
}


// MARK: - place suggest

public struct SuggestPlaceResult {
    
    public let query: String
    public let places: [PlaceSnippet]
    public let cursor: String?
    
    public var isDefaultList: Bool {
        return self.query.isEmpty
    }
    
    public init(query: String, places: [PlaceSnippet], cursor: String? = nil) {
        self.query = query
        self.places = places
        self.cursor = cursor
    }
    
    public init(default places: [PlaceSnippet]) {
        self.query = ""
        self.places = places
        self.cursor = nil
    }
}

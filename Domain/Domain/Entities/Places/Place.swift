//
//  Place.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct Coordinate {
    
    public let latt: Double
    public let long: Double
    
    public init(latt: Double, long: Double) {
        self.latt = latt
        self.long = long
    }
}


public struct Place {
    
    public enum RequireInfoProvider: String {
        case externalSearch
        case userDefine
        case placeOwner
    }
    
    public let uid: String
    public let title: String
    public let thumbnail: ImageSource?
    public let externalSearchID: String?
    public let detailLink: String?
    
    public let coordinate: Coordinate
    public let address: String
    public let contact: String?
    
    public var placeCategoryTags: [PlaceCategoryTag]
    
    public let reporterID: String
    public let requireInfoProvider: RequireInfoProvider
    public let createdAt: TimeSeconds
    public var placePickCount: Int
    public var lastPickedAt: TimeSeconds
    
    public init(uid: String, title: String,
                thumbnail: ImageSource? = nil,
                externalSearchID: String? = nil,
                detailLink: String? = nil,
                coordinate: Coordinate, address: String, contact: String? = nil,
                categoryTags: [PlaceCategoryTag], reporterID: String,
                infoProvider: RequireInfoProvider, createdAt: TimeSeconds,
                pickCount: Int, lastPickedAt: TimeSeconds) {
        self.uid = uid
        self.title = title
        self.thumbnail = thumbnail
        self.externalSearchID = externalSearchID
        self.detailLink = detailLink
        self.coordinate = coordinate
        self.address = address
        self.contact = contact
        self.placeCategoryTags = categoryTags
        self.reporterID = reporterID
        self.requireInfoProvider = infoProvider
        self.createdAt = createdAt
        self.placePickCount = pickCount
        self.lastPickedAt = lastPickedAt
    }
}

extension Coordinate: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latt == rhs.latt && lhs.long == rhs.long
    }
}


// MARK: - NewPlaceForm & Builder

public class NewPlaceForm {
    
    public let reporterID: String
    public let infoProvider: Place.RequireInfoProvider
    
    public var title: String = ""
    public var thumbnail: ImageSource?
    public var searchID: String?
    public var detailLink: String?
    public var coordinate: Coordinate!
    public var address: String = ""
    public var contact: String?
    public var categoryTags: [PlaceCategoryTag] = []
    
    public init(reporterID: String, infoProvider: Place.RequireInfoProvider) {
        self.reporterID = reporterID
        self.infoProvider = infoProvider
    }
}


public typealias NewPlaceFormBuilder = Builder<NewPlaceForm>

extension NewPlaceFormBuilder {
    
    public func build() -> Base? {
        
        let asserting: (NewPlaceForm) -> Bool = { form in
            guard form.title.isNotEmpty,
                  form.coordinate != nil,
                  form.address.isNotEmpty,
                  form.categoryTags.isNotEmpty else { return false }
            return true
        }
        return build(with: asserting)
    }
}

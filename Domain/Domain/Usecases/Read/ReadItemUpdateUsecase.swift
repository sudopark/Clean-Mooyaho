//
//  ReadItemUpdateUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


// MARK: - ReadItemUpdateParams

public struct ReadItemUpdateParams {
    
    public enum ProperyUpdateParams {
        case remindTime(_ newValue: TimeStamp?)
        case isRed(_ newValue: Bool)
        case parentID(_ newValue: String?)
        
        public func applyChange(to item: ReadItem) -> ReadItem {
            switch self {
            case let .remindTime(time):
                return item |> \.remindTime .~ time
                
            case let .isRed(flag):
                return (item as? ReadLink).map { $0 |> \.isRed .~ flag } ?? item
                
            case let .parentID(id):
                return item |> \.parentID .~ id
            }
        }
    }
    
    public let item: ReadItem
    public var updatePropertyParams: [ProperyUpdateParams] = []
    
    public init(item: ReadItem){
        self.item = item
    }
    
    public func applyChanges() -> ReadItem {
        return self.updatePropertyParams.reduce(self.item) { acc, property in
            return property.applyChange(to: acc)
        }
    }
}


// MARK: - ReadItemUpdateUsecase

public protocol ReadItemUpdateUsecase {
    
    func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void>
    
    func updateLink(_ link: ReadLink) -> Maybe<Void>
    
    func updateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
}


extension ReadItemUpdateUsecase {
    
    public func makeCollection(_ collection: ReadCollection,
                        at parentID: String?) -> Maybe<Void> {
        let newCollection = collection |> \.parentID .~ parentID
        return self.updateCollection(newCollection)
    }
    
    public func saveLink(_ link: String, at collectionID: String?) -> Maybe<Void> {
        let readLink = ReadLink(link: link) |> \.parentID .~ collectionID
        return self.updateLink(readLink)
    }
    
    public func saveLink(_ link: ReadLink, at collectionID: String?) -> Maybe<Void> {
        let readLink = link |> \.parentID .~ collectionID
        return self.updateLink(readLink)
    }
}

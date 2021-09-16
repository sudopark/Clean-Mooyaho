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


public protocol ReadItemUpdateUsecase {
    
    func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void>
    
    func saveLink(_ link: ReadLink, at collectionID: String?) -> Maybe<Void>
}


extension ReadItemUpdateUsecase {
    
    public func makeCollection(_ collection: ReadCollection,
                        at parentID: String?) -> Maybe<Void> {
        let newCollection = collection |> \.parentID .~ parentID
        return self.updateCollection(newCollection)
    }
    
    public func saveLink(_ link: String, at collectionID: String?) -> Maybe<Void> {
        let readLink = ReadLink(link: link)
        return self.saveLink(readLink, at: collectionID)
    }
}

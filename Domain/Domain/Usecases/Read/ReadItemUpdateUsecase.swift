//
//  ReadItemUpdateUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemUpdateUsecase {
    
    func makeCollection(_ collection: ReadCollection,
                        at parentID: String?) -> Maybe<Void>
    
    func updateCollection(_ newCollection: ReadCollection) -> Maybe<Void>
    
    func saveLink(_ link: String, at collectionID: String?) -> Maybe<Void>
    
    func saveLink(_ link: ReadLink, at collectionID: String?) -> Maybe<Void>
}

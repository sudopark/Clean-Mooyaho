//
//  SharedReadCollectionHandleUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol SharedReadCollectionHandleUsecase {
    
    func loadSharedCollection(by sharedURL: String) -> Maybe<ShareReadCollectionUsecase>
}

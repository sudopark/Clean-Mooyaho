//
//  ReadItemLoadUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemLoadUsecase {
    
    func loadMyItems() -> Observable<[ReadItem]>
    
    func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]>
}

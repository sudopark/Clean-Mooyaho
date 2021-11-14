//
//  ShareItemRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ShareItemRepository {
    
    func requestShareCollection(_ collection: ReadCollection) -> Maybe<SharedReadCollection>
    
    func requestStopShare(readCollection shareID: String) -> Maybe<Void>
    
    func requestLoadLatestsSharedCollections() -> Observable<[SharedReadCollection]>
}

//
//  HoorayRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol HoorayRepository {
    
    func fetchLatestHooray(_ memberID: String) -> Maybe<LatestHooray?>
    
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<LatestHooray?>
    
    func requestPublishHooray(_ newForm: NewHoorayForm,
                              withNewPlace: NewPlaceForm?) -> Maybe<Hooray>
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]>
    
    func requestAckHooray(_ myID: String, at hoorayID: String) -> Maybe<Void>
}

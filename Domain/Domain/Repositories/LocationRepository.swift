//
//  LocationRepository.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol LocationRepository {
    
    func uploadLocation(_ location: UserLocation) -> Maybe<Void>
}

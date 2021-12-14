//
//  DeviceInfoService.swift
//  Domain
//
//  Created by sudo.park on 2021/12/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol DeviceInfoService {
    
    func osVersion() -> String
    func appVersion() -> String
    func deviceModel() -> String
}

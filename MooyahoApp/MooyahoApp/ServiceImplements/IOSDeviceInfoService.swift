//
//  IOSDeviceInfoService.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain


final class IOSDeviceInfoService: DeviceInfoService { }

extension IOSDeviceInfoService {
    
    private func markettingVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.1"
    }
    
    private func buildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
    
    func appVersion() -> String {
        return "\(self.markettingVersion())(\(self.buildNumber()))"
    }
    
    func osVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    func deviceModel() -> String {
        return UIDevice.current.model
    }
}

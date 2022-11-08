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
        return ""
        // TODO: UIDevice 접근 시도시 MainActor 이여야함 -> 추후 수정 필요
//        return UIDevice.current.systemVersion
    }
    
    func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "unknown"
    }
}

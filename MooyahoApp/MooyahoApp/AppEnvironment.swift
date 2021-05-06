//
//  AppEnvironment.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum BuildMode {
    case debug
    case release
}


public struct AppEnvironment {
    
    public static var buildMode: BuildMode {
        #if DEBUG
            return .debug
        #elseif RELEASE
            return .release
        #endif
    }
    
    public static var isTestBuild: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        #endif
        return false
    }
}

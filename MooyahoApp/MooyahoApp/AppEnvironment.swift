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
    
    private static var secretJsons: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "secrets", ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]) ?? [:]
    }()
    
    public static var firebaseServiceKey: String? = {
        return secretJsons["firebase_server_key"] as? String
    }()
}

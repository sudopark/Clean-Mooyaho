//
//  AppEnvironment.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain

enum BuildMode {
    case debug
    case release
}

struct AppEnvironment {
    
    static var buildMode: BuildMode {
        #if DEBUG
            return .debug
        #elseif RELEASE
            return .release
        #endif
    }
    
    static var isTestBuild: Bool {
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
    
    static var firebaseServiceKey: String? = {
        return secretJsons["firebase_server_key"] as? String
    }()
    
    static var kakaoSignInAPIPath: String? = {
        return secretJsons["kakao_signin"] as? String
    }()
    
    static var appID: String {
        return "1565634642"
    }
    
    static var groupID: String {
        return "group.sudo.park.clean-mooyaho"
    }
    
    static var shareScheme: String {
        return "readminds"
    }
    
    static var dbFileName: String {
        if self.isTestBuild {
            return "test_dummy"
        } else {
            return "datamodels"
        }
    }
    
    
    static var featureFlag: FeatureFlagType = {
        if isTestBuild {
            return DummyFeatureFlag()
        } else {
            return FeatureFlags()
        }
    }()
    
    static var encryptedStorageIdentifier: String {
        return "readmind"
    }
    
    static func dataModelDBPath(for userID: String? = nil) -> String {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupID)
        
        let fileName = userID.map { "\(self.dbFileName)_\($0)" } ?? self.dbFileName
        let dbURL = directory?.appendingPathComponent("\(fileName).db")
        return dbURL?.path ?? ""
    }
    
    static var deviceID: String {
        let key = "moyaho.device.uuid"
        
        func makeAndSaveID() -> String {
            let newUUID = UUID().uuidString
            UserDefaults.standard.setValue(newUUID, forKey: key)
            return newUUID
        }
        
        func loadExisting() -> String? {
            return UserDefaults.standard.string(forKey: key)
        }
        
        return loadExisting() ?? makeAndSaveID()
    }
    
    static var welcomeItemURLPath: String {
        if self.buildMode == .debug {
            return "http://localhost:3000/welcome"
        } else {
            return "https://breadroad-af5c0.web.app/welcome"
        }
    }
}


public struct DummyFeatureFlag: FeatureFlagType {
    
    public func enable(_ feature: Feature) { }
    
    public func disable(_ feature: Feature) { }
    
    public func isEnable(_ feature: Feature) -> Bool {
        return true
    }
}

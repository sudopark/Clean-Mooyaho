//
//  ShareExtensionEnvironment.swift
//  ReadReminderShareExtension
//
//  Created by sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


final class ShareExtensionEnvironment {
    
    static var isTestBuild: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        #endif
        return false
    }
    
    static var firebaseServiceKey: String? = {
        return secretJsons["firebase_server_key"] as? String
    }()
    
    private static var secretJsons: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "secrets", ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]) ?? [:]
    }()
    
    static var dbFileName: String {
        if self.isTestBuild {
            return "test_dummy"
        } else {
            return "datamodels"
        }
    }
    
    static var groupID: String {
        return "group.sudo.park.clean-mooyaho"
    }
    
    static var shareScheme: String {
        return "readminds"
    }
    
    static func dataModelDBPath(for userID: String? = nil) -> String {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupID)
        
        let fileName = userID.map { "\(self.dbFileName)_\($0)" } ?? self.dbFileName
        let dbURL = directory?.appendingPathComponent("\(fileName).db")
        return dbURL?.path ?? ""
    }
}

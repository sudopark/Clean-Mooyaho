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
    
    static var legacyAPIPath: String? = {
        return secretJsons["legacy_api_path"] as? String
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
}

enum PlaceCategoryTags: String, CaseIterable {
    
    case restraunt
    case bar
    case cafe
    case travel
    case dailyLife
    case partyOrFestival
    case drive
    case feeling
    case work
    case weather
    case school
    case invest
    case home
    case dating
    case performanceOrMovie
    case congratulations
    case hobby
    case excerciseOrActivity
    
    private var emoji: String {
        switch self {
        case .restraunt: return "🍽"
        case .bar: return "🍸"
        case .cafe: return "☕️"
        case .travel: return "✈️"
        case .dailyLife: return "🕰"
        case .partyOrFestival: return "💃"
        case .drive: return "🚗"
        case .feeling: return "🤪"
        case .work: return "💼"
        case .weather: return "⛈"
        case .school: return "👩‍🏫"
        case .invest: return "🤑"
        case .home: return "🏡"
        case .dating: return "😍"
        case .performanceOrMovie: return "🍿"
        case .congratulations: return "🎉"
        case .hobby: return "🎸"
        case .excerciseOrActivity: return "🏄‍♂️"
        }
    }
    
    var tag: PlaceCategoryTag {
        return .init(placeCat: self.rawValue.localized, emoji: self.emoji)
    }
}

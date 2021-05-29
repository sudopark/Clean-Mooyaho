//
//  Logger.swift
//  Domain
//
//  Created by sudo.park on 2021/05/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public let logger: Logger = Logger()

public struct Logger {
    
    public enum Level {
        
        case verbose
        case warning
        case error
        case info
        case goal
        
        var key: String {
            switch self {
            case .verbose: return "VERBOS"
            case .warning: return "WARN"
            case .error: return "ERROR"
            case .info: return "INFO"
            case .goal: return "GOAL"
            }
        }
        
        var emoji: String {
            switch self {
            case .verbose: return ""
            case .warning: return "🚨"
            case .error: return "🤢"
            case .info: return "🤖"
            case .goal: return "🎯"
            }
        }
    }
}


extension Logger {
    
    private var current: String {
        let format = DateFormatter()
        return format.string(from: Date())
    }
    
    public func print(level: Level, _ message: String) {
        Swift.print("\(level.emoji) [\(level.key)] - \(current): \(message)")
    }
    
    public func todoImplement(_ function: StaticString = #function) {
        Swift.print("☠️ - \(current): should implement -> \(function)")
    }
}

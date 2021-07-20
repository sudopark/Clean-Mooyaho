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
        
        case debug
        case warning
        case error
        case info
        case goal
        
        var key: String {
            switch self {
            case .debug: return "DEBUG"
            case .warning: return "WARN"
            case .error: return "ERROR"
            case .info: return "INFO"
            case .goal: return "GOAL"
            }
        }
        
        var emoji: String {
            switch self {
            case .debug: return "💬"
            case .warning: return "🚨"
            case .error: return "🤢"
            case .info: return "⛳️"
            case .goal: return "🎯"
            }
        }
    }
}


extension Logger {
    
    private var current: String {
        let format = DateFormatter()
        format.dateFormat = "y-MM-dd H:m:ss.SSSS"
        return format.string(from: Date())
    }
    
    private func fileName(_ name: StaticString) -> String {
        let compoes = "\(name)".components(separatedBy: "/")
        return compoes.last ?? ""
    }
    
    public func print(level: Level, _ message: String, file: StaticString = #file, line: UInt = #line) {
        Swift.print("\(current): [\(level.emoji)][\(level.key)][\(self.fileName(file)) \(line)L] -> \(message)")
    }
    
    public func todoImplement(message: String? = nil,
                              _ function: StaticString = #function,
                              file: StaticString = #file, line: UInt = #line) {
        Swift.print("\n\n\(current): [☠️☠️☠️☠️☠️][TODO] \(message ?? "") [\(self.fileName(file)) \(line)L] -> \(function) [☠️☠️☠️☠️☠️]")
    }
}

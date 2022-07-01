//
//  Logger.swift
//  Domain
//
//  Created by sudo.park on 2021/05/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public let logger: Logger = Logger()

public final class Logger {
    
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
    
    private var crashLogger: CrashLogger?
}


public struct SecureLoggingMessage {
    public var fullText: String = ""
    public var secureField: [Any] = []
    
    public init() { }
    
    var message: String {
        let fieldTexts = secureField.map { "\($0)" }
        return String(format: fullText, arguments: fieldTexts)
    }
    
    var securedMessage: String {
        let obfuscatedFields = self.secureField.map { _ in "***" }
        return String(format: fullText, arguments: obfuscatedFields)
    }
}

extension Logger {
    
    public func attachCrashLogger(_ logger: CrashLogger) {
        self.crashLogger = logger
    }
    
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
        
        let buildMessage: () -> String = {
            return "\(self.current): [\(level.emoji)][\(level.key)][\(self.fileName(file)) \(line)L] -> \(message)"
        }
        
        #if DEBUG
            Swift.print(buildMessage())
        #endif
        self.crashLogger?.log(buildMessage())
    }
    
    public func print(level: Level, _ secureMessage: SecureLoggingMessage, file: StaticString = #file, line: UInt = #line) {
        
        #if DEBUG
        Swift.print("\(self.current): [\(level.emoji)][\(level.key)][\(self.fileName(file)) \(line)L] -> \(secureMessage.message)")
        #endif
        self.crashLogger?.log("\(self.current): [\(level.emoji)][\(level.key)][\(self.fileName(file)) \(line)L] -> \(secureMessage.securedMessage)")
    }
    
    public func todoImplement(message: String? = nil,
                              _ function: StaticString = #function,
                              file: StaticString = #file, line: UInt = #line) {
        Swift.print("\n\n\(current): [☠️☠️☠️☠️☠️][TODO] \(message ?? "") [\(self.fileName(file)) \(line)L] -> \(function) [☠️☠️☠️☠️☠️]")
    }
}

//
//  RuntimeError.swift
//  Extensions
//
//  Created by sudo.park on 2022/06/26.
//

import Foundation


public struct RuntimeError: Error {
    
    public let message: String
    public init(
        _ message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.message = "\(file):\(line) - \(message)"
    }
}

//
//  RuntimeError.swift
//  Extensions
//
//  Created by sudo.park on 2022/06/26.
//

import Foundation


public struct RuntimeError: Error {
    
    public let message: String
    public init(_ message: String) {
        self.message = message
    }
}

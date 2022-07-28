//
//  Sequence+Extensions.swift
//  Extensions
//
//  Created by sudo.park on 2022/07/29.
//

import Foundation


extension Sequence {
    
    public func asyncForEach(_ asyncTask: (Element) async throws -> Void) async rethrows {
        
        for element in self {
            try await asyncTask(element)
        }
    }
}

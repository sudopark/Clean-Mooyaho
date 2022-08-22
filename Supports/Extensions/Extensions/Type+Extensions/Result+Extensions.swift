//
//  Result+Extensions.swift
//  Extensions
//
//  Created by sudo.park on 2022/07/30.
//

import Foundation


extension Result where Success == Void {
    
    public func throwOrNot() throws {
        switch self {
        case .success: return
        case .failure(let error): throw error
        }
    }
}


extension Result where Success == Any {
    
    public func unwrapSuccessOrThrow<T>() throws -> T? {
        let resultWithType = self.map { $0 as? T }
        switch resultWithType {
        case .success(let t): return t
        case .failure(let error): throw error
        }
    }
}


extension Result {
    
    public func unwrapSuccessOrThrowWithoutCasting() throws -> Success {
        switch self {
        case .success(let s): return s
        case .failure(let error): throw error
        }
    }
}

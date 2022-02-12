//
//  Combine+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/12.
//

import Foundation

import Combine


extension AnyPublisher {
    
    public func ignoreErrorAsNever(fallback: Output? = nil) -> AnyPublisher<Output, Never> {
        
        let asOptional: (Output) -> Output? = { $0 }
        
        let catchTransform: (Failure) -> Just<Output?>
        catchTransform = { _ in
            return Just(fallback)
        }
        
        return self.map(asOptional)
            .catch(catchTransform)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

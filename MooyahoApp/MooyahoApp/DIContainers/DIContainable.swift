//
//  DIContainable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - DIContainable

public protocol DIContainable {
    
    associatedtype Dependency
    
    init(dependency: Dependency)
}

extension DIContainable where Dependency == Void {
    
    public init(dependency: Dependency) {
        self.init(dependency: ())
    }
}

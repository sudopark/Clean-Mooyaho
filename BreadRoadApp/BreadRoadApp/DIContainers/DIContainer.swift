//
//  Factory.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol DIContainer {
    
    associatedtype Dependency
    
    init(dependency: Dependency)
}


extension DIContainer where Dependency == Void {
    
    init(dependency: Dependency) {
        self.init(dependency: ())
    }
}

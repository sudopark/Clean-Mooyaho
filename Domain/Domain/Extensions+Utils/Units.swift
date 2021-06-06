//
//  Units.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public typealias Milliseconds = Int

public typealias Seconds = Int

public typealias Minutes = Int

public typealias Meters = Double

public typealias TimeStamp = TimeInterval

extension TimeStamp {
    
    public static func now() -> Self {
        return Date().timeIntervalSince1970
    }
}

extension Minutes {
    
    public func asSeconds() -> Seconds {
        return self * 60
    }
}


extension Seconds {
    
    public func asTimeInterval() -> TimeInterval {
        return TimeInterval(self)
    }
}

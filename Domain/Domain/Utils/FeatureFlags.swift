//
//  FeatureFlags.swift
//  Domain
//
//  Created by sudo.park on 2022/05/25.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Feature & FeatureFlagType

public enum Feature: String, CaseIterable {
    case welcomeItem
}

public protocol FeatureFlagType {
    
    func enable(_ feature: Feature)
    
    func disable(_ feature: Feature)
    
    func isEnable(_ feature: Feature) -> Bool
}


// MARK: - FeatureFlags

public final class FeatureFlags: FeatureFlagType {
    
    private var enableFeatures = Set<Feature>()
    
    public init() { }
}


extension FeatureFlags {
    
    public func enable(_ feature: Feature) {
        self.enableFeatures.insert(feature)
    }
    
    public func disable(_ feature: Feature) {
        self.enableFeatures.remove(feature)
    }
    
    public func isEnable(_ feature: Feature) -> Bool {
        return self.enableFeatures.contains(feature)
    }
}

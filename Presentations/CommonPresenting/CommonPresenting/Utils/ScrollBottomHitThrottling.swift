//
//  ScrollBottomHitThrottling.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/19.
//

import UIKit


public final class ScrollBottomHitThrottling {
    
    private let threshold: CGFloat
    private let throttleTime: TimeInterval
    
    public init(threshold: CGFloat = 0, throttleTime: TimeInterval = 1) {
        self.threshold = threshold
        self.throttleTime = throttleTime
    }
    
    private var lastTime: Date?
    
    public func didScrollBottomHit(by geometry: ViewGeometry) -> Bool {
        let thresholdY = geometry.contentSize.height - geometry.size.height - self.threshold
        guard geometry.offset > 0,
              geometry.offset >= thresholdY,
              self.isEnoughTimePassedForIgnoreThrottling()
        else {
            return false
        }
        self.lastTime = Date()
        return true
    }
    
    private func isEnoughTimePassedForIgnoreThrottling() -> Bool {
        guard let lastTime = lastTime else { return true }
        return Date().timeIntervalSince(lastTime) >= self.throttleTime
    }
}

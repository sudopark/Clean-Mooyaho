//
//  MapCameraFocus.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/10.
//

import Foundation

import Domain


public struct MapCameramovement {
    
    public enum Center {
        case coordinate(Coordinate)
        case currentUserPosition
    }
    
    public let center: Center
    public let radius: Meters
    public let withAnimation: Bool
    
    public init(center: Center,
                radius: Meters = 1_500,
                withAnimation: Bool = true) {
        self.center = center
        self.radius = radius
        self.withAnimation = withAnimation
    }
}

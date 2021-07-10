//
//  MapCameraFocus.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/10.
//

import Foundation

import Domain


public struct MapCameraFocus {
    
    public let coordinate: Coordinate
    public let animation: Bool
    
    public init(coordinate: Coordinate, withAnimation: Bool = false) {
        self.coordinate = coordinate
        self.animation = withAnimation
    }
}

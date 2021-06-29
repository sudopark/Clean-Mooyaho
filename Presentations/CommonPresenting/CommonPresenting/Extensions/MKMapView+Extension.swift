//
//  MKMapView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/30.
//

import UIKit

import MapKit


extension MKMapView {
    
    
    public func updateCameraToUserLocation(zoomDistanceLevel meters: Double = 1_500,
                                           with animation: Bool = true) {
        let location = self.userLocation
        self.updateCameraPosition(location.coordinate, distance: meters, animation: animation)
    }
    
    public func updateCameraPosition(latt: Double, long: Double,
                                     zoomDistanceLevel meters: Double = 1_500,
                                     with animation: Bool = true) {
        let center = CLLocationCoordinate2D(latitude: latt, longitude: long)
        self.updateCameraPosition(center, distance: meters, animation: animation)
        
    }
    
    private func updateCameraPosition(_ center: CLLocationCoordinate2D,
                                      distance: Double,
                                      animation: Bool) {
        let distance = CLLocationDistance(distance)
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: distance,
                                        longitudinalMeters: distance)
        self.setRegion(region, animated: animation)
    }
}

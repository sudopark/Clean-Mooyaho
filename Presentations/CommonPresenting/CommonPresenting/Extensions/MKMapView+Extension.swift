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


// AnnotationView

public protocol AnnotationView: MKAnnotationView {
    
    associatedtype Annotation: NSObject & MKAnnotation
    
    func setup(for annotation: Annotation)
}

extension MKMapView {
    
    public func register<V: AnnotationView>(annotationView type: V.Type,
                                            with customIdentifier: String? = nil) {
        let identifier = customIdentifier ?? NSStringFromClass(V.Annotation.self)
        self.register(V.self, forAnnotationViewWithReuseIdentifier: identifier)
    }
    
    public func registerMarkerAnnotationView<A: MKAnnotation>(for type: A.Type,
                                                              with customIdentifier: String? = nil) {
        let identifier = customIdentifier ?? NSStringFromClass(A.self)
        self.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
    }
    
    public func dequeue<V: AnnotationView>(for annotation: V.Annotation,
                                           with customIdentifier: String? = nil) -> V {
        let identifier = customIdentifier ?? NSStringFromClass(V.Annotation.self)
        return self.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! V
    }
    
    public func deqeueMarketAnnotationView<A: MKAnnotation>(for annotation: A,
                                                            with customIdentifier: String? = nil) -> MKMarkerAnnotationView {
        let identifier = customIdentifier ?? NSStringFromClass(A.self)
        return self.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation.self) as! MKMarkerAnnotationView
    }
}


extension MKAnnotation {
    
    public var isUserLocation: Bool {
        
        return self.isKind(of: MKUserLocation.self)
    }
}

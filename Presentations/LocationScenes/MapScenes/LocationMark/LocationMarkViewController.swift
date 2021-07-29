//
//  LocationMarkViewController.swift
//  MapScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - LocationMarkViewController

public final class LocationMarkViewController: BaseViewController, LocationMarkScene {
    
    let viewModel: LocationMarkViewModel
    let mapView = MKMapView()
    
    public init(viewModel: LocationMarkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
}

// MARK: - bind

extension LocationMarkViewController {
    
    private func bind() {
        
        self.viewModel.markerPosition
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] coordinate in
                self?.updateMarker(coordinate)
                
                let movement = MapCameramovement(center: .coordinate(coordinate),
                                                 radius: 100, withAnimation: false)
                self?.mapView.moveCamera(using: movement)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateMarker(_ coordinate: Coordinate) {
        let previousOne = self.mapView.annotations
        self.mapView.removeAnnotations(previousOne)
        
        let newAnnotation = MarkerAnnotation(coordinate)
        self.mapView.addAnnotation(newAnnotation)
    }
}

// MARK: - setup presenting

extension LocationMarkViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(mapView)
        mapView.autoLayout.fill(self.view)
    }
    
    public func setupStyling() {
        self.mapView.registerMarkerAnnotationView(for: MarkerAnnotation.self)
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.showsUserLocation = false
    }
}


class MarkerAnnotation: NSObject, MKAnnotation {

    @objc var coordinate: CLLocationCoordinate2D

    init(_ coordinate: Coordinate) {
        self.coordinate = .init(latitude: coordinate.latt, longitude: coordinate.long)
    }
}

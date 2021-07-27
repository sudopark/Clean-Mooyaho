//
//  NearbyViewController.swift
//  MapScenes
//
//  Created sudo.park on 2021/05/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - NearbyViewController

public final class NearbyViewController: BaseViewController, NearbyScene {
    
    let mapView = MKMapView()
    let dimView = UIView()
    
    let viewModel: NearbyViewModel
    
    public init(viewModel: NearbyViewModel) {
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

extension NearbyViewController {
    
    private func bind() {
        
        self.viewModel.cameraPosition
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] camera in
                self?.updateCameraPosition(camera)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.alertUnavailToUseService
            .subscribe(onNext: { [weak self] in
                self?.dimView.isHidden = false
            })
            .disposed(by: self.disposeBag)
       
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.preparePermission()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateCameraPosition(_ position: MapCameraPosition) {
        guard let center = position.center else {
            self.mapView.updateCameraToUserLocation()
            return
        }
        self.mapView.updateCameraPosition(latt: center.latitude, long: center.longitude)
    }
}

// MARK: - setup presenting

extension NearbyViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.mapView)
        mapView.autoLayout.fill(self.view)
        
        self.view.addSubview(dimView)
        dimView.autoLayout.fill(self.view)
    }
    
    public func setupStyling() {
        
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        self.dimView.backgroundColor = UIColor.black
        self.dimView.alpha = 0.1
        self.dimView.isHidden = true
    }
}


extension NearbyViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let newLocation = userLocation.location else { return }
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(newLocation) { [weak self] placeMark, error in
            guard error == nil, let mark = placeMark?.first,
                  let placeMarkString = mark.name ?? mark.locality else {
                return
            }
            self?.viewModel.userPositionChanged(placeMarkString)
        }
    }
}


private extension MapCameraPosition {
    
    var center: CLLocationCoordinate2D? {
        switch self {
        case let .default(position):
            return .init(latitude: position.latt, longitude: position.long)
         case let .userLocation(position):
            guard let position = position else { return nil }
            return .init(latitude: position.latt, longitude: position.long)
        }
    }
}

class UserLocationAnnotation: MKPointAnnotation { }

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
import Overture

import Domain
import CommonPresenting


// MARK: - NearbyViewController

public final class NearbyViewController: BaseViewController, NearbyScene {
    
    let mapView = MKMapView()
    let dimView = UIView()
    
    let viewModel: NearbyViewModel
    
    private let spread_circle_animation_duration: TimeInterval = 5.0
    
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
        
        self.viewModel.moveCamera
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] movement in
                self?.mapView.moveCamera(using: movement)
//                guard case let .coordinate(coordi) = movement.center else { return }
//                self?.startHoorayFocusInOutAnimation(at: coordi)
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
                self?.bindHoorayMarkers()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindHoorayMarkers() {
        self.viewModel.recentNearbyHoorays
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] markers in
                logger.print(level: .debug, "recent hoorays: \(markers)")
                self?.appendHoorayMarkers(markers)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.newHooray
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] marker in
                self?.appendHoorayMarkers([marker])
                marker.isNew.then {
                    self?.startSpreadAnimations(marker.coordinate)
                }
                marker.withFocusAnimation.then {
                    self?.startHoorayFocusInOutAnimation(at: marker.coordinate)
                }
            })
            .disposed(by: self.disposeBag)
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
        self.mapView.register(annotationView: HoorayMarkerAnnotationView.self)
        self.mapView.delegate = self
        
        self.dimView.backgroundColor = UIColor.black
        self.dimView.alpha = 0.1
        self.dimView.isHidden = true
    }
}

// MARK: - handle animation & markers

extension NearbyViewController {
    
    private func appendHoorayMarkers(_ markers: [HoorayMarker]) {
        
        let annotations = markers.map{ HoorayMarkerAnnotation(marker: $0) }
        self.mapView.addAnnotations(annotations)
        
        self.scheduleRemoveHoorayMarkers(markers)
    }
    
    private func scheduleRemoveHoorayMarkers(_ markers: [HoorayMarker]) {
        
        let asFutureRemovingTimeEvents: (HoorayMarker) -> Observable<String>? = { marker in
            let remainTime = Int(marker.removeAt - TimeStamp.now())
            guard remainTime > 0 else { return nil }
            return Observable<Int>.timer(.milliseconds(remainTime), scheduler: MainScheduler.instance)
                .map { _ in marker.hoorayID }
        }
        let futureRemovings = markers.compactMap(asFutureRemovingTimeEvents)
        let removeHooray: (String) -> Void = { [weak self] hoorayID in
            guard let self = self,
                  let annotation = self.mapView
                    .annotations.first(where: { ($0 as? HoorayMarkerAnnotation)?.marker.hoorayID == hoorayID }) else {
                return
            }
            self.mapView.removeAnnotation(annotation)
        }
        self.disposeBag.insert(futureRemovings.map{ $0.subscribe(onNext: removeHooray) })
    }
    
    private func startHoorayFocusInOutAnimation(at coordinate: Coordinate) {
        
        let originSpan = self.mapView.region.span
        
        let startFocusIn: () -> Void = { [weak self] in
            let moveFocusIn = MapCameramovement(center: .coordinate(coordinate),
                                                radius: 100, withAnimation: true)
            self?.mapView.moveCamera(using: moveFocusIn)
        }
        
        let focusedIn = self.regionChanged().filter{ $0 }.take(1)
        
        let startSpreadAnimation: (Bool) -> Void = { [weak self] _ in
            self?.startSpreadAnimations(coordinate)
        }
        
        let thenFocusOut: (Bool) -> Void = { [weak self] _ in
            let rollbackSpaceDistance = originSpan.latitudeDelta < 100
                ? Policy.hoorayDefaultSpreadDistance : originSpan.latitudeDelta
            let moveFocusOut = MapCameramovement(center: .coordinate(coordinate),
                                                 radius: rollbackSpaceDistance, withAnimation: true)
            self?.mapView.moveCamera(using: moveFocusOut)
        }
        
        focusedIn
            .do(onNext: startSpreadAnimation)
            .delay(.milliseconds(1_500), scheduler: MainScheduler.instance)
            .subscribe(onNext: thenFocusOut)
            .disposed(by: self.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: startFocusIn)
    }
    
    private func startSpreadAnimations(_ center: Coordinate) {
        (0..<3).forEach { index in
            let delay = TimeInterval(index) * 1.2
            self.appendOverlayAndScheduleRemoving(center, delay: delay)
        }
    }
    
    private func appendOverlayAndScheduleRemoving(_ center: Coordinate, delay: TimeInterval) {
        
        let appendOverlay: () -> String? = { [weak self] in
            guard let self = self else { return nil }
            let center = CLLocationCoordinate2D(latitude: center.latt, longitude: center.long)
            let overlay = SpreadingOverlayCircle(center: center, radius: 100)
            self.mapView.addOverlay(overlay)
            
            return overlay.uuid
        }
        
        let waitAndRemoveOverlay: (String?) -> Void = { [weak self] overlayID in
            guard let self = self, let id = overlayID else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.spread_circle_animation_duration) {
                let targetOverlays = self.mapView.overlays.compactMap{ $0 as? SpreadingOverlayCircle }
                    .filter{ $0.uuid == id }
                self.mapView.removeOverlays(targetOverlays)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay,
                                      execute: pipe(appendOverlay, waitAndRemoveOverlay))
    }
}


// MARK: - handle mapView

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
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isUserLocation == false,
              let hoorayAnnotation = annotation as? HoorayMarkerAnnotation else { return nil }
        
        let annotationView: HoorayMarkerAnnotationView = mapView.dequeue(for: hoorayAnnotation)
        annotationView.canShowCallout = false
        annotationView.bindUserInfo(self.viewModel.memberInfo(hoorayAnnotation.marker.publisherID))
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let spreadingOverlay = overlay as? SpreadingOverlayCircle else {
            return MKCircleRenderer()
        }

        let decorating = concat(
            set(\MKCircleRenderer.fillColor, .red),
            set(\MKCircleRenderer.strokeColor, .clear),
            set(\MKCircleRenderer.alpha, 0.5)
        )
        return with(MKCircleRenderer(circle: spreadingOverlay), decorating)
    }
    
    public func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        
        let spreadRenders = renderers.filter{ $0.overlay is SpreadingOverlayCircle }
        
        let expandingWithFadeOutAnimation: (MKOverlayRenderer) -> Void = { renderer in
            
            renderer.alpha = 0.5
            
            UIView.animate(withDuration: self.spread_circle_animation_duration) {
                renderer.alpha = 0.0
            }
        }
        
        spreadRenders.forEach(expandingWithFadeOutAnimation)
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { }
}


private extension NearbyViewController {
    
    func regionChanged() -> Observable<Bool> {
        return self.rx.methodInvoked(#selector(mapView(_:regionDidChangeAnimated:)))
            .compactMap{ $0.last as? Bool }
    }
}

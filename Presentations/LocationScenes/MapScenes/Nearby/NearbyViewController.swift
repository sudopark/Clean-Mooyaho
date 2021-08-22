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
//                self?.startHoorayFocusInOutAnimation(at: coordi,
//                                                     withSpreading: Policy.hoorayDefaultSpreadDistance)
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
                marker.withFocusAnimation.then {
                    self?.startHoorayFocusInOutAnimation(at: marker.coordinate,
                                                         withSpreading: marker.isNew ? marker.spreadDistance : nil)
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
    
    private func startHoorayFocusInOutAnimation(at coordinate: Coordinate,
                                                withSpreading distance: Meters?) {
        
        let originSpan = self.mapView.region.span
        
        let startFocusIn: () -> Void = { [weak self] in
            let moveFocusIn = MapCameramovement(center: .coordinate(coordinate),
                                                radius: 100, withAnimation: true)
            self?.mapView.moveCamera(using: moveFocusIn)
        }
        
        let focusedIn = self.regionChanged().filter{ $0 }.take(1)
        
        let startSpreadAnimation: (Bool) -> Void = { [weak self] _ in
            guard let self = self, let distance = distance else { return }
            self.startSpreadAnimations(coordinate, distance: distance )
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
            .delay(.milliseconds(350), scheduler: MainScheduler.instance)
            .subscribe(onNext: thenFocusOut)
            .disposed(by: self.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: startFocusIn)
    }
    
    private func startSpreadAnimations(_ center: Coordinate, distance: Meters) {
        (0..<3).forEach { index in
            let delay = TimeInterval(index) * 1.2
            self.appendAndUpdateSpraedOverlay(center, spreadDistance: distance, delay: delay)
        }
    }
    
    private func appendAndUpdateSpraedOverlay(_ center: Coordinate, spreadDistance: Meters, delay: TimeInterval) {
        
        let uuid = UUID().uuidString
        
        let spreadMetersPerSec: Double = 200
        let (interval, duration) = (TimeInterval(0.05), spreadDistance / spreadMetersPerSec)
        let frameCount = Int(duration / interval)
        
        let animationProgresses: Observable<Double> = Observable<Int>
            .interval(.milliseconds(Int(interval * 1000)), scheduler: MainScheduler.instance)
            .map{ Double($0) / Double(frameCount-1) }
            .take(frameCount)
        
        let refreshOverlayByProgress: (Double) -> Void = { [weak self] progress in
            guard let self = self else { return }
            self.mapView.removeCircleOverlay(uuid)
            
            guard progress < 1.0 else { return }
            self.mapView.appendCircleOverlay(uuid, at: center, progess: progress, finalDistance: spreadDistance)
        }
        
        animationProgresses
            .delaySubscription(.milliseconds(Int(delay * 1_000)), scheduler: MainScheduler.instance)
            .subscribe(onNext: refreshOverlayByProgress)
            .disposed(by: self.disposeBag)
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
        annotationView.bindMarkerIcon(self.viewModel.hoorayMarkerImage(hoorayAnnotation.marker))
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let hoorayAnnotationView = view as? HoorayMarkerAnnotationView,
              let annotation = hoorayAnnotationView.annotation as? HoorayMarkerAnnotation else { return }
        hoorayAnnotationView.markerSelected()
        self.viewModel.toggleSelectHooray(annotation.marker.hoorayID, isSelected: true)
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let hoorayAnnotationView = view as? HoorayMarkerAnnotationView,
              let annotation = hoorayAnnotationView.annotation as? HoorayMarkerAnnotation else { return }
        hoorayAnnotationView.markerDeSelected()
        self.viewModel.toggleSelectHooray(annotation.marker.hoorayID, isSelected: false)
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let spreadingOverlay = overlay as? SpreadingOverlayCircle else {
            return MKCircleRenderer()
        }

        let decorating = concat(
            set(\MKCircleRenderer.fillColor, .red),
            set(\MKCircleRenderer.alpha, spreadingOverlay.alpha)
        )
        return with(MKCircleRenderer(overlay: spreadingOverlay), decorating)
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { }
}


private extension NearbyViewController {
    
    func regionChanged() -> Observable<Bool> {
        return self.rx.methodInvoked(#selector(mapView(_:regionDidChangeAnimated:)))
            .compactMap{ $0.last as? Bool }
    }
}

private extension MKMapView {
    
    func removeCircleOverlay(_ uuid: String) {
        guard let overlay = self.overlays.first(where: { ($0 as? SpreadingOverlayCircle)?.uuid == uuid }) else {
            return
        }
        self.removeOverlay(overlay)
    }
    
    func appendCircleOverlay(_ uuid: String, at center: Coordinate, progess: Double, finalDistance: Meters) {
        
        let radius = finalDistance * progess
        let alpha = 0.5 - progess/2
        let center = CLLocationCoordinate2D(latitude: center.latt, longitude: center.long)
        let overlay = SpreadingOverlayCircle(center: center, radius: radius, uuid: uuid)
        overlay.alpha = CGFloat(alpha)
        self.addOverlay(overlay)
    }
}

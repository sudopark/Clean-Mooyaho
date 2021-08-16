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
        
        self.viewModel.moveCamera
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] movement in
                self?.mapView.moveCamera(using: movement)
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
                self?.appendHoorayMarkers(markers, withSpreadAnimation: false)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.newHooray
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] marker in
                self?.appendHoorayMarkers([marker], withSpreadAnimation: true)
                marker.withFocusAnimation.then {
                    self?.moveFocusOnNewPublishedHooray(marker.coordinate)
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


extension NearbyViewController: MKMapViewDelegate {
    
    private func appendHoorayMarkers(_ markers: [HoorayMarker], withSpreadAnimation: Bool) {
        
        let annotations = markers.map{ HoorayMarkerAnnotation(marker: $0) }
        self.mapView.addAnnotations(annotations)
        
        self.scheduleRemoveHoorayMarkers(markers)
        
        // TODO: start spread animations
    }
    
    private func moveFocusOnNewPublishedHooray(_ coordinate: Coordinate) {
        let movement = MapCameramovement(center: .coordinate(coordinate), radius: 100, withAnimation: true)
        self.mapView.moveCamera(using: movement)
    }
    
    private func scheduleRemoveHoorayMarkers(_ markers: [HoorayMarker]) {
        
        let asScheduleRemoving: (HoorayMarker) -> Observable<String>? = { marker in
            let remainTime = Int(marker.removeAt - TimeStamp.now())
            guard remainTime > 0 else { return nil }
            return Observable<Int>.timer(.milliseconds(remainTime), scheduler: MainScheduler.instance)
                .map { _ in marker.hoorayID }
        }
        let futureRemovings = markers.compactMap(asScheduleRemoving)
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
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        logger.print(level: .debug, "region did change with animation?: \(animated)")
    }
}


final class HoorayMarkerAnnotation: NSObject, MKAnnotation {
    
    let marker: HoorayMarker
    @objc var coordinate: CLLocationCoordinate2D
    
    init(marker: HoorayMarker) {
        self.marker = marker
        self.coordinate = .init(latitude: marker.coordinate.latt, longitude: marker.coordinate.long)
    }
}

final class HoorayMarkerAnnotationView: MKAnnotationView, AnnotationView, Presenting {
    
    typealias Annotation = HoorayMarkerAnnotation
    
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
    private let publisherImageView = IntegratedImageView()
    
    private var disposeBag = DisposeBag()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupLayout()
        self.setupStyling()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.publisherImageView.cancelSetupImage()
        
        print("prepare for resus.........")
    }
    
    func setup(for annotation: HoorayMarkerAnnotation) { }
    
    func bindUserInfo(_ source: Observable<Member>) {
        
        source
            .distinctUntilChanged{ $0.icon == $1.icon }
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] member in
                let icon = member.icon ?? Member.memberDefaultEmoji
                self?.publisherImageView
                    .setupImage(using: icon, resize: .init(width: 25, height: 25))
            })
            .disposed(by: self.disposeBag)
    }
}


extension HoorayMarkerAnnotationView {
    
    func setupLayout() {
        
        self.frame = .init(x: 0, y: 0, width: 30, height: 30)
        
        self.addSubview(backgroundView)
        backgroundView.autoLayout.fill(self)
        
        self.backgroundView.contentView.addSubview(publisherImageView)
        publisherImageView.autoLayout.fill(self.backgroundView,
                                           edges: .init(top: 2.5, left: 2.5,
                                                        bottom: 2.5, right: 2.5),
                                           withSafeArea: false)
        publisherImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 25)
            $0.heightAnchor.constraint(equalToConstant: 25)
        }
        publisherImageView.setupLayout()
    }
    
    func setupStyling() {
        
        self.backgroundView.clipsToBounds = true
        self.backgroundView.layer.cornerRadius = 15
        
        self.publisherImageView.setupStyling()
    }
}

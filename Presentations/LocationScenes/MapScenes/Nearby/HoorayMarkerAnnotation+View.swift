//
//  HoorayMarkerAnnotation+View.swift
//  MapScenes
//
//  Created by sudo.park on 2021/08/20.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - HoorayMarkerAnnotation

final class HoorayMarkerAnnotation: NSObject, MKAnnotation {
    
    let marker: HoorayMarker
    @objc var coordinate: CLLocationCoordinate2D
    
    init(marker: HoorayMarker) {
        self.marker = marker
        self.coordinate = .init(latitude: marker.coordinate.latt, longitude: marker.coordinate.long)
    }
}


// MARK: - HoorayMarkerAnnotationView

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
    }
    
    func setup(for annotation: HoorayMarkerAnnotation) { }

    func bindMarkerIcon(_ source: Observable<Thumbnail>) {
        
        source
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] icon in
                let iconSizeWhenExpanding: CGSize = .init(width: 25, height: 25)
                self?.publisherImageView.setupImage(using: icon, resize: iconSizeWhenExpanding)
            })
            .disposed(by: self.disposeBag)
    }
    
    func markerSelected() {
        self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
    }
    
    func markerDeSelected() {
        self.transform = .identity
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


// MARK: - SpreadingOverlayCircle

final class SpreadingOverlayCircle: MKCircle {
    
    var uuid: String?
    var alpha: CGFloat = 0.5
    
    convenience init(center coord: CLLocationCoordinate2D,
                     radius: CLLocationDistance,
                     uuid: String?) {
        self.init(center: coord, radius: radius)
        self.uuid = uuid
    }
}

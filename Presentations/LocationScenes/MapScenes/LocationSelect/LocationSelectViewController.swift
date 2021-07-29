//
//  LocationSelectViewController.swift
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

class BottomContainerView: BaseUIView, InputKeyboardHandlable {
    
    var bottomOffset: CGFloat = 10
    weak var movingContentBottomConsttaint: NSLayoutConstraint?
}

// MARK: - LocationSelectViewController

public final class LocationSelectViewController: BaseViewController, LocationSelectScene {
    
    let mapView = MKMapView()
    let centerImageView = UIImageView()
    let bottomSlideMenuView = BottomContainerView()
    let addressExplainLabel = UILabel()
    let addressTextView = UITextView()
    let confirmButton = ConfirmButton(type: .system)

    let viewModel: LocationSelectViewModel
    
    public init(viewModel: LocationSelectViewModel) {
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

extension LocationSelectViewController {
    
    private func bind() {
        
        self.bottomSlideMenuView.bindKeyboardFrameChangesIfPossible()?
            .disposed(by: self.disposeBag)
        
        self.viewModel.addrees
            .asDriver(onErrorDriveWith: .never())
            .drive(self.addressTextView.rx.text)
            .disposed(by: self.disposeBag)
        
        self.addressTextView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.updateAddress(text)
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] enable in
                self?.confirmButton.isEnabled = enable
                self?.confirmButton.alpha = enable ? 1.0 : 0.5
            })
            .disposed(by: self.disposeBag)
        
        self.showPreviousSelectedInfoIfNeed()
    }
    
    private func showPreviousSelectedInfoIfNeed() {
        guard let info = self.viewModel.previousSelectedInfo else {
            self.mapView.moveCamera(using: .init(center: .currentUserPosition, radius: 150, withAnimation: false))
            return
        }
        self.mapView.moveCamera(using: .init(center: .coordinate(info.coordinate),
                                             radius: 150, withAnimation: false))
    }
}

extension LocationSelectViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        self.viewModel.selectCurrentLocation(.init(latt: center.latitude, long: center.longitude))
        self.view.endEditing(true)
    }
}

// MARK: - setup presenting

extension LocationSelectViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(mapView)
        mapView.autoLayout.fill(self.view)
        
        self.view.addSubview(centerImageView)
        centerImageView.autoLayout.active(with: self.view) {
            $0.widthAnchor.constraint(equalToConstant: 25)
            $0.heightAnchor.constraint(equalToConstant: 25)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: -20)
        }
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
        }
        let constraint = bottomSlideMenuView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        constraint.isActive = true
        bottomSlideMenuView.movingContentBottomConsttaint = constraint
        
        bottomSlideMenuView.addSubview(addressExplainLabel)
        addressExplainLabel.autoLayout.active(with: bottomSlideMenuView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        addressExplainLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        bottomSlideMenuView.addSubview(addressTextView)
        addressTextView.autoLayout.active(with: bottomSlideMenuView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: addressExplainLabel.bottomAnchor, constant: 6)
            $0.heightAnchor.constraint(equalToConstant: 60)
        }
        
        bottomSlideMenuView.addSubview(confirmButton)
        confirmButton.setupLayout(self.bottomSlideMenuView)
        confirmButton.autoLayout.active {
            $0.topAnchor.constraint(equalTo: addressTextView.bottomAnchor, constant: 12)
        }
    }
    
    public func setupStyling() {
        
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        self.centerImageView.tintColor = .systemRed
        self.centerImageView.image = UIImage(named: "flag.fill")
        
        self.bottomSlideMenuView.backgroundColor = self.uiContext.colors.appBackground
        self.bottomSlideMenuView.layer.cornerRadius = 10
        self.bottomSlideMenuView.clipsToBounds = true
        
        self.addressExplainLabel.numberOfLines = 1
        self.addressExplainLabel.textColor = .darkGray
        self.addressExplainLabel.font = UIFont.systemFont(ofSize: 12)
        self.addressExplainLabel.text = "Address"
        
        self.addressTextView.textColor = self.uiContext.colors.text
        self.addressTextView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        self.confirmButton.setupStyling()
        self.confirmButton.setTitle("Confirm Select", for: .normal)
    }
}


private extension CLLocationCoordinate2D {
    
    func placeMark() -> Observable<String?> {
        
        return Observable.create { observer in
            
            let encoder = CLGeocoder()
            let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
            encoder.reverseGeocodeLocation(location) { marks, error in
                
                guard error == nil, let mark = marks?.first else {
                    struct UnknownError: Error {}
                    observer.onError(error ?? UnknownError())
                    return
                }
                observer.onNext(mark.convert().address)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

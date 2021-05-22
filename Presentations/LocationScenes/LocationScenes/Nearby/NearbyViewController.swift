//
//  NearbyViewController.swift
//  LocationScenes
//
//  Created sudo.park on 2021/05/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - NearbyScene

public protocol NearbyScene: Scenable { }


// MARK: - NearbyViewController

public final class NearbyViewController: BaseViewController, NearbyScene {
    
    let mapView = MKMapView()
    
    private let viewModel: NearbyViewModel
    
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
        
    }
}

// MARK: - setup presenting

extension NearbyViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.mapView)
        mapView.autoLayout.activeFill(self.view)
    }
    
    public func setupStyling() {
        
    }
}

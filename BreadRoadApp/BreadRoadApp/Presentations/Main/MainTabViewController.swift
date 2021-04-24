//
//  MainTabViewController.swift
//  BreadRoadApp
//
//  Created ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Domain

// MARK: - MainTabScene

public protocol MainTabScene: Scenable { }


// MARK: - MainTabViewController

public final class MainTabViewController: BaseViewController, MainTabScene {
    
    private let viewModel: MainTabViewModel
    
    public init(viewModel: MainTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.testPresentViewControllerName()
    }
    
}

// MARK: - bind

extension MainTabViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension MainTabViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}

//
//  RegisterNewPlaceViewController.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - RegisterNewPlaceViewController

public final class RegisterNewPlaceViewController: BaseViewController, RegisterNewPlaceScene {
    
    let viewModel: RegisterNewPlaceViewModel
    
    public init(viewModel: RegisterNewPlaceViewModel) {
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

extension RegisterNewPlaceViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension RegisterNewPlaceViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}

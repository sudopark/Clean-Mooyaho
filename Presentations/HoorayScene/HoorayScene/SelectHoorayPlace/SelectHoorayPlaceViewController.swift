//
//  SelectHoorayPlaceViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SelectHoorayPlaceViewController

public final class SelectHoorayPlaceViewController: BaseViewController, SelectHoorayPlaceScene {
    
    let viewModel: SelectHoorayPlaceViewModel
    
    public init(viewModel: SelectHoorayPlaceViewModel) {
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

extension SelectHoorayPlaceViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension SelectHoorayPlaceViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}

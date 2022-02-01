//
//  ReadCollectionMainViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - ReadCollectionMainViewController

public final class ReadCollectionMainViewController: BaseNavigationController, ReadCollectionMainScene {
    
    let viewModel: ReadCollectionMainViewModel
    
    public init(viewModel: ReadCollectionMainViewModel) {
        self.viewModel = viewModel
        super.init(shouldHideNavigation: false)
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
        
        self.viewModel.setupSubCollections()
    }
    
}

// MARK: - bind

extension ReadCollectionMainViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension ReadCollectionMainViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        self.navigationBar.backgroundColor = self.uiContext.colors.appBackground
    }
}

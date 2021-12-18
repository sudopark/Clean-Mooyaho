//
//  AddItemNavigationViewController.swift
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - AddItemNavigationViewController

public final class AddItemNavigationViewController: BaseViewController, AddItemNavigationScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    let viewModel: AddItemNavigationViewModel
    public var navigationdContainerView: UIView {
        return self.bottomSlideMenuView.containerView
    }
    
    public init(viewModel: AddItemNavigationViewModel) {
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
        
        self.viewModel.prepareNavigation()
    }
    
    public func requestCloseScene() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - bind

extension AddItemNavigationViewController {
    
    private func bind() {
        
        self.bindBottomSlideMenuView()
    }
}

// MARK: - setup presenting

extension AddItemNavigationViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
    }
}

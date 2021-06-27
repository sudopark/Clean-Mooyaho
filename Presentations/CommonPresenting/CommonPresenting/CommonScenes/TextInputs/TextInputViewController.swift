//
//  TextInputViewController.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - TextInputViewController

public final class TextInputViewController: BaseViewController, TextInputScene {
    
    let bottomSlideMenuView = BaseBottomSlideMenuView()
    let titleLabel = UILabel()
    let inputTextView = InputTextView()
    let charCountLabel = UILabel()
    let confirmButton = UIButton()
    
    let viewModel: TextInputViewModel
    
    public init(viewModel: TextInputViewModel) {
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

extension TextInputViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension TextInputViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
        
        self.view.addSubview(titleLabel)
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
    }
}

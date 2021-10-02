//
//  EditLinkItemViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - EditLinkItemViewController

public final class EditLinkItemViewController: BaseViewController, EditLinkItemScene {
    
    let viewModel: EditLinkItemViewModel
    
    public init(viewModel: EditLinkItemViewModel) {
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

extension EditLinkItemViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension EditLinkItemViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}

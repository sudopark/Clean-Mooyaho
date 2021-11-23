//
//  IntegratedSearchViewController.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - IntegratedSearchViewController

public final class IntegratedSearchViewController: BaseViewController, IntegratedSearchScene {
    
    private let tableView = UITableView()
    public let suggestSceneContainer: UIView = UIView()
    
    let viewModel: IntegratedSearchViewModel
    
    public init(viewModel: IntegratedSearchViewModel) {
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
        self.viewModel.setupSubScene()
    }
    
}

// MARK: - bind

extension IntegratedSearchViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension IntegratedSearchViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view)
        
        self.view.addSubview(suggestSceneContainer)
        suggestSceneContainer.autoLayout.fill(self.view)
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = .red
    }
}

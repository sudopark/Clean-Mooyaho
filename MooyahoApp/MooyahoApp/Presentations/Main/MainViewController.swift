//
//  MainViewController.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - MainScene

public protocol MainScene: Scenable { }


// MARK: - MainViewController

public final class MainViewController: BaseNavigationController, MainScene {
    
    private let mainView = MainView()
    private let viewModel: MainViewModel
    
    
    public init(viewModel: MainViewModel) {
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
        self.testPresentViewControllerName()
        self.bind()
    }

}

// MARK: - bind

extension MainViewController {
    
    private func bind() {
    
        
        self.mainView.navigationBarView.profileImageView.rx
            .addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.openSlideMenu()
            })
            .disposed(by: self.dispsoseBag)
    }
}

// MARK: - setup presenting

extension MainViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.mainView)
        mainView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
        }
        mainView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.context.colors.appBackground
        
        self.mainView.setupStyling()
    }
}

//
//  MainSlideMenuViewController.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - MainSlideMenuScene

public protocol MainSlideMenuScene: Scenable, PangestureDismissableScene { }


// MARK: - MainSlideMenuViewController

public final class MainSlideMenuViewController: BaseViewController, MainSlideMenuScene {
    
    let containerView = UIView()
    let dimView = UIView()
    
    private let viewModel: MainSlideMenuViewModel
    public var dismissalInteractor: PangestureDismissalInteractor?

    public init(viewModel: MainSlideMenuViewModel) {
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
    
    public func setupDismissGesture(_ dismissInteractor: PangestureDismissalInteractor) {
        let bindDismissInteractor: () -> Void = { [weak self, weak dismissInteractor] in
            guard let self = self, let interactor = dismissInteractor else { return }
            interactor.addLeftDismissPangesture(self.view) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: self.disposeBag)
        }
        
        self.rx.viewDidLoad
            .map{ _ in }
            .subscribe(onNext: bindDismissInteractor)
            .disposed(by: self.disposeBag)
    }
}

// MARK: - bind

extension MainSlideMenuViewController {
    
    private func bind() {
        
        self.dimView.isUserInteractionEnabled = true
        self.dimView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.closeMenu()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension MainSlideMenuViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.dimView)
        dimView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.2)
        }
        
        self.view.addSubview(self.containerView)
        containerView.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.8)
        }
    }
    
    public func setupStyling() {
        
        self.view.isUserInteractionEnabled = true
        
        self.dimView.alpha = 0.1
        
        self.containerView.backgroundColor = self.context.colors.raw.red
    }
}

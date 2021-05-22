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
    
    private let viewModel: MainSlideMenuViewModel
    public var dismissalInteractor: PangestureDismissalInteractor?
    
    private let mainSlideView = MainSlideMenuView()
    
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
        
    }
}

// MARK: - setup presenting

extension MainSlideMenuViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.mainSlideView)
        self.mainSlideView.autoLayout.activeFill(self.view)
        self.mainSlideView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.mainSlideView.setupStyling()
    }
}

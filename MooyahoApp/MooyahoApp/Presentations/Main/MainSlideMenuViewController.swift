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

import Domain
import CommonPresenting


// MARK: - MainSlideMenuScene

public protocol MainSlideMenuSceneInteractor: Sendable, SettingMainSceneListenable, DiscoveryMainSceneListenable { }

public protocol MainSlideMenuSceneListenable: AnyObject, Sendable {
    
    func mainSlideMenuDidRequestSignIn()
}

public protocol MainSlideMenuScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: MainSlideMenuSceneInteractor? { get }
    @MainActor var discoveryContainerView: UIView { get }
}

extension MainSlideMenuViewController {
    
    public nonisolated var interactor: MainSlideMenuSceneInteractor? {
        return self.viewModel as? MainSlideMenuSceneInteractor
    }
}


// MARK: - MainSlideMenuViewController

public final class MainSlideMenuViewController: BaseViewController, MainSlideMenuScene {
    
    let containerView = UIView()
    let dimView = UIView()
    let bottomBarView = UIView()
    let settingButton = UIButton(type: .system)
//    let alertButton = UIButton(type: .system)
//    let alertBadgeView = UIView()
    public let discoveryContainerView = UIView()
    let actionSuggestView = ActionSuggestView()
    let discoveryBlockView = UIView()
    
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
        self.viewModel.refresh()
    }
    
    public func setupDismissGesture(_ dismissInteractor: PangestureDismissalInteractor) {
        let bindDismissInteractor: () -> Void = { [weak self, weak dismissInteractor] in
            guard let self = self, let interactor = dismissInteractor else { return }
            interactor.addDismissPangesture(self.view) { [weak self] in
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
        
        self.viewModel.isDiscovable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.discoveryBlockView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        self.viewModel.suggestingAction
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] action in
                self?.actionSuggestView.update(by: action)
            })
            .disposed(by: self.disposeBag)
        
        self.actionSuggestView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.suggestingActionRequested()
            })
            .disposed(by: self.disposeBag)
        
        self.settingButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.openSetting()
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
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.8)
        }
        
        containerView.addSubview(self.bottomBarView)
        bottomBarView.autoLayout.active(with: self.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 60)
        }
        let bottomBackgrounView = UIView()
        bottomBackgrounView.backgroundColor = UIColor(red: 22/255, green: 27/255, blue: 34/255, alpha: 1)
        containerView.addSubview(bottomBackgrounView)
        bottomBackgrounView.autoLayout.active(with: containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.topAnchor.constraint(equalTo: bottomBarView.topAnchor)
        }
        self.containerView.bringSubviewToFront(bottomBarView)
        
        self.bottomBarView.addSubview(self.settingButton)
        settingButton.autoLayout.active(with: bottomBarView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
        }
        
//        self.bottomBarView.addSubview(self.alertButton)
//        alertButton.autoLayout.active(with: settingButton) {
//            $0.trailingAnchor.constraint(equalTo: $1.leadingAnchor, constant: -16)
//            $0.topAnchor.constraint(equalTo: $1.topAnchor)
//            $0.widthAnchor.constraint(equalToConstant: 20)
//            $0.heightAnchor.constraint(equalToConstant: 20)
//        }
//
//        self.bottomBarView.addSubview(self.alertBadgeView)
//        alertBadgeView.autoLayout.active(with: self.alertButton) {
//            $0.widthAnchor.constraint(equalToConstant: 6)
//            $0.heightAnchor.constraint(equalToConstant: 6)
//            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 2)
//            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -2)
//        }
        
        self.bottomBarView.addSubview(actionSuggestView)
        actionSuggestView.autoLayout.active(with: self.bottomBarView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
//            $0.centerYAnchor.constraint(equalTo: alertButton.centerYAnchor, constant: 2)
//            $0.trailingAnchor.constraint(equalTo: alertButton.leadingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: settingButton.centerYAnchor, constant: 2)
            $0.trailingAnchor.constraint(equalTo: settingButton.leadingAnchor, constant: -20)
        }
        actionSuggestView.setupLayout()
        
        self.containerView.addSubview(discoveryContainerView)
        discoveryContainerView.autoLayout.active(with: self.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: bottomBackgrounView.topAnchor)
        }
        
        self.containerView.addSubview(discoveryBlockView)
        discoveryBlockView.autoLayout.fill(discoveryContainerView)
    }
    
    public func setupStyling() {
        
        self.view.isUserInteractionEnabled = true
        
        self.dimView.alpha = 0.1
        
        self.containerView.backgroundColor = UIColor(red: 30/255, green: 34/255, blue: 40/255, alpha: 1)
        
        self.settingButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        self.settingButton.tintColor = UIColor.from(hex: "#CFD8DC")?.withAlphaComponent(0.6)
        
//        self.alertButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
//        self.alertButton.tintColor = UIColor.from(hex: "#CFD8DC")?.withAlphaComponent(0.6)
//
//        self.alertBadgeView.backgroundColor = UIColor.systemRed
//        self.alertBadgeView.layer.cornerRadius = 3
//        self.alertBadgeView.clipsToBounds = true
//        self.alertBadgeView.isHidden = true
        
        self.actionSuggestView.setupStyling()
        
        self.discoveryBlockView.isHidden = true
    }
}


// MARK: - ActionSuggestView

class ActionSuggestView: BaseUIView {
    
    let statusView = UIView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    func update(by action: SuggestingAction) {
        switch action {
        case .signIn:
            self.statusView.alpha = 0.1
            self.titleLabel.text = "Login is required".localized
            self.descriptionLabel.text = "Click to log in to the service.".localized
            
        case let .editProfile(userName):
            self.statusView.alpha = 1.0
            self.titleLabel.text = userName ?? "No nickname".localized
            self.descriptionLabel.text = "Click to set up your profile.".localized
        }
    }
}

extension ActionSuggestView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(statusView)
        statusView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.widthAnchor.constraint(equalToConstant: 12)
            $0.heightAnchor.constraint(equalToConstant: 12)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 32)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
        }
        self.titleLabel.numberOfLines = 1
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self) {
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.5)
        }
        self.descriptionLabel.numberOfLines = 1
        self.descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func setupStyling() {
        
        self.backgroundColor = UIColor(red: 35/255, green: 37/255, blue: 41/255, alpha: 1.0)
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        self.statusView.backgroundColor = UIColor.systemGreen
        self.statusView.alpha = 0.1
        self.statusView.layer.cornerRadius = 6
        self.statusView.clipsToBounds = true
        
        self.titleLabel.font = self.uiContext.fonts.get(13, weight: .medium)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = UIColor.from(hex: "#fefefe")
        self.titleLabel.text = "--"
        
        self.descriptionLabel.font = self.uiContext.fonts.get(11, weight: .medium)
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        self.descriptionLabel.text = "--"
    }
}

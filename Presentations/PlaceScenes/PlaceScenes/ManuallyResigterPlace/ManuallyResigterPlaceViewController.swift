//
//  ManuallyResigterPlaceViewController.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - ManuallyResigterPlaceViewController

public final class ManuallyResigterPlaceViewController: BaseViewController, ManuallyResigterPlaceScene {
    
    let titleLabel = UILabel()
    let mapContainerView = UIView()
    let placeInfoSectionView = InfoSectionView<UILabel>()
    let tagInfoSectionView = InfoSectionView<UILabel>()
    let confirmButton = LoadingButton()
    
    public var childContainerView: UIView {
        return self.mapContainerView
    }
    
    private var titleTopConstraint: NSLayoutConstraint!
    
    let viewModel: ManuallyResigterPlaceViewModel
    
    public init(viewModel: ManuallyResigterPlaceViewModel) {
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

extension ManuallyResigterPlaceViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension ManuallyResigterPlaceViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        }
        self.titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 24)
        self.titleTopConstraint.isActive = true
        
        self.view.addSubview(mapContainerView)
        mapContainerView.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 120)
        }
        
        self.view.addSubview(placeInfoSectionView)
        placeInfoSectionView.autoLayout.active(with: titleLabel) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        placeInfoSectionView.setupLayout()
        
        self.view.addSubview(tagInfoSectionView)
        tagInfoSectionView.autoLayout.active(with: self.placeInfoSectionView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        tagInfoSectionView.setupLayout()
        tagInfoSectionView.innerView.autoLayout.active {
            $0.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        }
        self.confirmButton.setupLayout()
    }
    
    public func setupStyling() {
        
        self.titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        self.titleLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.6)
        self.titleLabel.text = "Enter a name"
        
        self.placeInfoSectionView.setupStyling()
        self.placeInfoSectionView.innerView.numberOfLines = 1
        self.placeInfoSectionView.innerView.lineBreakMode = .byTruncatingTail
        self.placeInfoSectionView.underLineView.isHidden = true
        self.placeInfoSectionView.innerView.attributedText = "Select a place".with(attribute: Attribute.placeHolder)
        
        self.tagInfoSectionView.setupStyling()
        self.tagInfoSectionView.innerView.attributedText = Attribute.tagPlaceHolder
        
        self.confirmButton.backgroundColor = UIColor.systemBlue
        self.confirmButton.title = "Confirm"
        self.confirmButton.setupStyling()
        self.confirmButton.layer.cornerRadius = 4
        self.confirmButton.clipsToBounds = true
    }
}

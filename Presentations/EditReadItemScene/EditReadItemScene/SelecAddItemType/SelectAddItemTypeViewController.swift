//
//  SelectAddItemTypeViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting

// MARK: - SelectAddItemTypeViewController


final class ItemTypeView: BaseUIView, Presenting {
    
    let addIconView = UIImageView()
    let titleLabel = UILabel()
    let itemTypeImageView = UIImageView()
    let underLineView = UIView()
    
    func setupLayout() {
        self.addSubview(addIconView)
        addIconView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: addIconView.trailingAnchor, constant: 12)
        }
        
        self.addSubview(itemTypeImageView)
        itemTypeImageView.autoLayout.active(with: self) {
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8)
        }
        
        self.addSubview(underLineView)
        underLineView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
    }
    
    func setupStyling() {
        
        self.addIconView.image = UIImage(systemName: "plus")
        self.addIconView.tintColor = self.uiContext.colors.buttonBlue
        
        _ = self.titleLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.numberOfLines .~ 1
            |> \.textColor .~ self.uiContext.colors.buttonBlue
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

public final class SelectAddItemTypeViewController: BaseViewController, SelectAddItemTypeScene, BottomSlideViewSupporatble {
    
    let titleLabel = UILabel()
    public let bottomSlideMenuView = BaseBottomSlideMenuView()
    let buttonsStackView = UIStackView()
    let addCollectionButtonView = ItemTypeView()
    let addLinkButtonView = ItemTypeView()
    
    let viewModel: SelectAddItemTypeViewModel
    
    public init(viewModel: SelectAddItemTypeViewModel) {
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
    
    public func requestCloseScene() {
        self.viewModel.closeScene()
    }
}

// MARK: - bind

extension SelectAddItemTypeViewController {
    
    private func bind() {
        
        self.bindBottomSlideMenuView()
        
        self.addCollectionButtonView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.requestAddNewCollection()
            })
            .disposed(by: self.disposeBag)
        
        self.addLinkButtonView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.requestAddNewReadLink()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension SelectAddItemTypeViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        self.bottomSlideMenuView.containerView.addSubview(buttonsStackView)
        buttonsStackView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -60)
        }
        
        self.buttonsStackView.axis = .vertical
        self.buttonsStackView.addArrangedSubview(addCollectionButtonView)
        self.addCollectionButtonView.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 50)
        }
        self.buttonsStackView.addArrangedSubview(addLinkButtonView)
        self.addLinkButtonView.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 50)
        }
        addCollectionButtonView.setupLayout()
        addLinkButtonView.setupLayout()
    }
    
    public func setupStyling() {
                
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ pure("Select a new item type".localized)
        
        self.addCollectionButtonView.setupStyling()
        self.addCollectionButtonView.itemTypeImageView.image = UIImage(systemName: "folder")
        self.addCollectionButtonView.itemTypeImageView.tintColor = self.uiContext.colors.buttonBlue
        self.addCollectionButtonView.titleLabel.text = "Add a new collection".localized
        
        self.addLinkButtonView.setupStyling()
        self.addLinkButtonView.itemTypeImageView.image = UIImage(systemName: "doc.text")
        self.addLinkButtonView.itemTypeImageView.tintColor = self.uiContext.colors.buttonBlue
        self.addLinkButtonView.titleLabel.text = "Add a new read link".localized
    }
}

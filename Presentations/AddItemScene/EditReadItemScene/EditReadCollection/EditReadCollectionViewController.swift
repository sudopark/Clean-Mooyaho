//
//  EditReadCollectionViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting

// MARK: - EditReadCollectionViewController

public final class EditReadCollectionViewController: BaseViewController, EditReadCollectionScene {
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let underLineView = UIView()
    private let attributeStackView = UIStackView()
    private let priorityLabelView = KeyAndLabeledValueView()
    private let categoriesLabelView = KeyAndLabeledValueView()
    private let addPriorityButton = UIButton()
    private let addCategoryButton = UIButton()
    private let confirmButton = ConfirmButton()
    
    let viewModel: EditReadCollectionViewModel
    
    public init(viewModel: EditReadCollectionViewModel) {
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

extension EditReadCollectionViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension EditReadCollectionViewController: Presenting {
    
    
    public func setupLayout() {
        self.view.addSubview(self.confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        
        self.view.addSubview(attributeStackView)
        attributeStackView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20)
        }
        
        attributeStackView.axis = .vertical
        attributeStackView.addArrangedSubview(priorityLabelView)
        attributeStackView.addArrangedSubview(categoriesLabelView)
        attributeStackView.addArrangedSubview(addPriorityButton)
        attributeStackView.addArrangedSubview(addCategoryButton)
        priorityLabelView.autoLayout.active(with: attributeStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        priorityLabelView.setupLayout()
        priorityLabelView.labelView.limitHeight(max: 18)
        categoriesLabelView.autoLayout.active(with: attributeStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        categoriesLabelView.setupLayout()
        categoriesLabelView.labelView.limitHeight(max: 18)
        
        self.view.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: attributeStackView.topAnchor, constant: -16)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
        self.view.addSubview(textField)
        textField.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: underLineView.topAnchor, constant: -8)
        }
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: self.underLineView.topAnchor, constant: -8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
    }
    
    public func setupStyling() {
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Add new collection"
        
        _ = self.textField
            |> \.font .~ self.uiContext.fonts.get(14, weight: .regular)
            |> \.placeholder .~ "Enter a collection name"
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        self.priorityLabelView.isHidden = true
        self.categoriesLabelView.isHidden = true
        self.addPriorityButton.isHidden = false
        self.addCategoryButton.isHidden = false
        
        self.addPriorityButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.addPriorityButton.titleLabel?.font = self.uiContext.fonts.get(15, weight: .medium)
        self.addPriorityButton.setTitle("+ set a priority", for: .normal)
        self.addPriorityButton.contentHorizontalAlignment = .leading
        
        self.addCategoryButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.addCategoryButton.titleLabel?.font = self.uiContext.fonts.get(15, weight: .medium)
        self.addCategoryButton.setTitle("+ add some category", for: .normal)
        self.addCategoryButton.contentHorizontalAlignment = .leading
        
        self.priorityLabelView.setupStyling()
        self.categoriesLabelView.setupStyling()
        
        self.confirmButton.setupStyling()
        self.confirmButton.isEnabled = false
    }
}
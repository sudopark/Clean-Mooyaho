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
import Prelude
import Optics

import CommonPresenting

// MARK: - EditLinkItemViewController

public final class EditLinkItemViewController: BaseViewController, EditLinkItemScene {
    
    private let titleInputField = UITextField()
    private let underLineView = UIView()
    
    private let previewView = LinkPreviewView()
    private let previewShimmerView = PreviewShimmerView()
    
    private let attributeStackView = UIStackView()
    private let priorityLabelView = KeyAndLabeledValueView()
    private let categoriesLabelView = KeyAndLabeledValueView()
    private let addPriorityButton = UIButton()
    private let addCategoryButton = UIButton()
    
    private let confirmButton = ConfirmButton()
    
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
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
}

// MARK: - bind

extension EditLinkItemViewController {
    
    private func bind() {
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.rewind()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindPreview()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.itemSuggestedTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.titleInputField.text = title
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindPreview() {
        
        self.viewModel.linkPreviewStatus
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] status in
                self?.updatePreviewView(by: status)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.preparePreview()
    }
    
    private func updatePreviewView(by status: LoadPreviewStatus) {
        
        func startShimmerAnimation() {
            self.previewView.isHidden = true
            self.previewShimmerView.isHidden = false
            self.previewShimmerView.startAnimation()
        }
        
        func stopShimmerAnimation() {
            self.previewShimmerView.stopAnimation()
            self.previewShimmerView.isHidden = true
            self.previewView.isHidden = false
        }
        
        switch status {
        case .loading:
            startShimmerAnimation()
            
        case .loaded(let url, let preview):
            stopShimmerAnimation()
            self.previewView.updatePreview(url: url, preview: preview)
            
        case .loadFail(let url):
            stopShimmerAnimation()
            self.previewView.setLoadpreviewFail(for: url)
        }
    }
}

// MARK: - setup presenting

extension EditLinkItemViewController: Presenting {
    
    
    public func setupLayout() {
        
        let button = UIBarButtonItem(title: "< Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = button
        
        self.view.addSubview(confirmButton)
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
        
        self.view.addSubview(previewShimmerView)
        previewShimmerView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: attributeStackView.topAnchor, constant: -12)
            $0.heightAnchor.constraint(equalToConstant: 70)
        }
        previewShimmerView.setupLayout()
        
        self.view.addSubview(previewView)
        previewView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: attributeStackView.topAnchor, constant: -12)
            $0.heightAnchor.constraint(greaterThanOrEqualTo: previewShimmerView.heightAnchor)
        }
        previewView.setupLayout()
        
        self.view.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: previewShimmerView.topAnchor, constant: -16)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: previewView.topAnchor, constant: -16)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
        self.view.addSubview(titleInputField)
        titleInputField.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: underLineView.topAnchor, constant: -8)
        }
    }
    
    public func setupStyling() {
        
        confirmButton.setupStyling()
        
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
        
        self.previewView.setupStyling()
        self.previewView.isHidden = true
        self.previewShimmerView.setupStyling()
        self.previewShimmerView.isHidden = false
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        _ = self.titleInputField
            |> \.font .~ self.uiContext.fonts.get(16, weight: .medium)
            |> \.placeholder .~ "Enter a Custom name"
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
    }
}

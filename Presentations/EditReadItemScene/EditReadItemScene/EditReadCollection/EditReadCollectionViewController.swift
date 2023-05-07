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

import Domain
import CommonPresenting
import Extensions


// MARK: - EditReadCollectionViewController

public final class EditReadCollectionViewController: BaseViewController, EditReadCollectionScene,
                                                     BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let descriptionInputField = UITextField()
    private let underLineView = UIView()
    private let attributeStackView = UIStackView()
    private let collectionPathView = CollectionPathView()
    private let priorityLabelView = KeyAndLabeledValueView()
    private let categoriesLabelView = KeyAndLabeledValueView()
    private let remindLabelView = KeyAndLabeledValueView()
    private let addPriorityButton = UIButton()
    private let addCategoryButton = UIButton()
    private let addRemindButton = UIButton()
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
    
    public func requestCloseScene() {
        self.viewModel.closeScene()
    }
}

// MARK: - bind

extension EditReadCollectionViewController {
    
    private func bind() {
        
        self.bindBottomSlideMenuView()
        
        self.setupInitialAttributeIfPossible()
        
        self.textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.enterName(text)
            })
            .disposed(by: self.disposeBag)
        
        self.descriptionInputField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.enterDescription(text)
            })
            .disposed(by: self.disposeBag)
        
        self.collectionPathView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.changeParentCollection()
            })
            .disposed(by: self.disposeBag)
        
        let editPriorityTrigger = Observable.merge (
            self.addPriorityButton.rx.throttleTap(),
            self.priorityLabelView.rx.addTapgestureRecognizer().map { _ in },
            self.priorityLabelView.rightButton.rx.throttleTap()
        )
        editPriorityTrigger
            .subscribe(onNext: { [weak self] in
                self?.viewModel.addPriority()
            })
            .disposed(by: self.disposeBag)
        
        let editCategoryTrigger = Observable.merge(
            self.addCategoryButton.rx.throttleTap(),
            self.categoriesLabelView.rx.addTapgestureRecognizer().map { _ in },
            self.categoriesLabelView.rightButton.rx.throttleTap()
        )
        editCategoryTrigger
            .subscribe(onNext: { [weak self] in
                self?.viewModel.addCategory()
            })
            .disposed(by: self.disposeBag)
        
        let editRemindTrigger = Observable.merge(
            self.addRemindButton.rx.throttleTap(),
            self.remindLabelView.rx.addTapgestureRecognizer().map { _ in },
            self.remindLabelView.rightButton.rx.throttleTap()
        )
        editRemindTrigger
            .subscribe(onNext: { [weak self] in
                self?.viewModel.addRemind()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmUpdate()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isProcessing
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isLoading)
            .disposed(by: self.disposeBag)
        
        self.viewModel.parentCollectionName
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] name in
                self?.updateParentCollectionName(name)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.priority
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] priority in
                self?.updatePriorityLabel(priority)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.categories
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] categories in
                self?.updateCategoryLabel(categories)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.remindTime
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] time in
                self?.updateRemindLabel(time)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    private func updateParentCollectionName(_ name: String) {
        self.collectionPathView.isHidden.then {
            self.collectionPathView.isHidden = false
        }
        self.collectionPathView.nameLabel.text = name
    }
    
    private func setupInitialAttributeIfPossible() {
        guard let colleciton = self.viewModel.editCaseCollectionValue else { return }
        self.titleLabel.text = "Edit Collection".localized
        self.textField.text = colleciton.name
        self.descriptionInputField.text = colleciton.collectionDescription
    }
    
    private func updatePriorityLabel(_ newValue: ReadPriority?) {
        self.addPriorityButton.isHidden = newValue != nil
        self.priorityLabelView.isHidden = newValue == nil
        newValue.do <| priorityLabelView.labelView.setupPriority(_:)
    }
    
    private func updateCategoryLabel(_ newValue: [ItemCategory]) {
        self.addCategoryButton.isHidden = newValue.isNotEmpty
        self.categoriesLabelView.isHidden = newValue.isEmpty
        pure(newValue).do <| categoriesLabelView.labelView.updateCategories(_:)
    }
    
    private func updateRemindLabel(_ time: TimeStamp?) {
        self.addRemindButton.isHidden = time != nil
        self.remindLabelView.isHidden = time == nil
        time.do <| remindLabelView.labelView.setupRemind(_:)
    }
}

// MARK: - setup presenting

extension EditReadCollectionViewController: Presenting {
    
    public func setupLayout() {
        self.setupBottomSlideLayout()
        
        bottomSlideMenuView.containerView.addSubview(self.confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        
        bottomSlideMenuView.containerView.addSubview(attributeStackView)
        attributeStackView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20)
        }
        
        attributeStackView.axis = .vertical
        attributeStackView.spacing = 8
        attributeStackView.addArrangedSubview(collectionPathView)
        attributeStackView.addArrangedSubview(priorityLabelView)
        attributeStackView.addArrangedSubview(categoriesLabelView)
        attributeStackView.addArrangedSubview(remindLabelView)
        attributeStackView.addArrangedSubview(addPriorityButton)
        attributeStackView.addArrangedSubview(addCategoryButton)
        attributeStackView.addArrangedSubview(addRemindButton)
        collectionPathView.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 32)
        }
        collectionPathView.setupLayout()
        priorityLabelView.autoLayout.active(with: attributeStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        priorityLabelView.setupLayout()
        categoriesLabelView.autoLayout.active(with: attributeStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        categoriesLabelView.setupLayout()
        categoriesLabelView.labelView.limitHeight(max: 25)
        
        remindLabelView.setupLayout()
        remindLabelView.labelView.limitHeight(max: 25)
        
        bottomSlideMenuView.containerView.addSubview(underLineView)
        underLineView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: attributeStackView.topAnchor, constant: -16)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
        
        bottomSlideMenuView.containerView.addSubview(descriptionInputField)
        descriptionInputField.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: underLineView.topAnchor, constant: -8)
        }
        
        bottomSlideMenuView.containerView.addSubview(textField)
        textField.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: descriptionInputField.topAnchor, constant: -12)
        }
        
        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: self.textField.topAnchor, constant: -16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> { self.uiContext.decorating.smallHeader($0) }
            |> \.text .~ pure("Add a new collection".localized)
        
        _ = self.textField
            |> \.font .~ self.uiContext.fonts.get(14, weight: .regular)
            |> \.placeholder .~ pure("Enter a collection name".localized)
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
        
        let descriptionColor: UIColor? = self.uiContext.colors.descriptionText
        _ = self.descriptionInputField
            |> \.font .~ self.uiContext.fonts.get(13, weight: .regular)
            |> \.placeholder .~ pure("Collection description".localized)
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
            |> \.textColor .~ descriptionColor
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        self.collectionPathView.setupStyling()
        self.collectionPathView.isHidden = true
        self.priorityLabelView.isHidden = true
        self.categoriesLabelView.isHidden = true
        self.remindLabelView.isHidden = true
        self.addPriorityButton.isHidden = false
        self.addCategoryButton.isHidden = false
        self.addRemindButton.isHidden = false
        
        self.addPriorityButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.addPriorityButton.titleLabel?.font = self.uiContext.fonts.get(15, weight: .medium)
        self.addPriorityButton.setTitle("+ set a priority".localized, for: .normal)
        self.addPriorityButton.contentHorizontalAlignment = .leading
        
        self.addCategoryButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.addCategoryButton.titleLabel?.font = self.uiContext.fonts.get(15, weight: .medium)
        self.addCategoryButton.setTitle("+ add some category".localized, for: .normal)
        self.addCategoryButton.contentHorizontalAlignment = .leading
        
        self.addRemindButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.addRemindButton.titleLabel?.font = self.uiContext.fonts.get(15, weight: .medium)
        self.addRemindButton.setTitle("+ add remind".localized, for: .normal)
        self.addRemindButton.contentHorizontalAlignment = .leading
        
        self.priorityLabelView.setupStyling()
        self.priorityLabelView.iconView.image = UIImage(systemName: "arrow.up.arrow.down.square")
        self.priorityLabelView.keyLabel.text = "Priority".localized
        self.priorityLabelView.updateRightButtonIsHidden(false)
        
        self.categoriesLabelView.setupStyling()
        self.categoriesLabelView.iconView.image = UIImage(systemName: "line.horizontal.3.decrease.circle")
        self.categoriesLabelView.keyLabel.text = "Categories".localized
        self.categoriesLabelView.updateRightButtonIsHidden(false)
        
        self.remindLabelView.setupStyling()
        self.remindLabelView.iconView.image = UIImage(systemName: "alarm")
        self.remindLabelView.keyLabel.text = "Remind".localized
        self.remindLabelView.updateRightButtonIsHidden(false)
        
        self.confirmButton.setupStyling()
        self.confirmButton.isEnabled = false
    }
}

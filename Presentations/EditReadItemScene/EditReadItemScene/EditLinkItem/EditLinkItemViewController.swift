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

import Domain
import CommonPresenting
import Extensions


class CollectionPathView: BaseUIView, Presenting {
    
    let iconView = UIImageView()
    let nameLabel = UILabel()
    let arrowView = UIImageView()
    
    func setupLayout() {
        
        self.addSubview(iconView)
        iconView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.addSubview(arrowView)
        arrowView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 8)
            $0.heightAnchor.constraint(equalToConstant: 22)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        
        self.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8)
        }
    }
    
    func setupStyling() {
        
        _ = self.iconView
            |> \.image .~ UIImage(systemName: "folder")
            |> \.tintColor .~ self.uiContext.colors.buttonBlue
            |> \.contentMode .~ .scaleAspectFit
        
        _ = nameLabel
            |> { self.uiContext.decorating.listItemTitle($0) }
            |> \.numberOfLines .~ 1
            |> \.textColor .~ self.uiContext.colors.buttonBlue
        
        _ = self.arrowView
            |> \.image .~ UIImage(systemName: "chevron.right")
            |> \.contentMode .~ .scaleAspectFit
            |> \.tintColor .~ self.uiContext.colors.buttonBlue
    }
}


// MARK: - EditLinkItemViewController

public final class EditLinkItemViewController: BaseViewController, EditLinkItemScene {
    
    private enum Metric {
        static var topSpacingForPullGuideVisible: (Bool) -> CGFloat {
            return { $0 ? 0 : -24 }
        }
        
    }
    
    private let pullGuideView = PullGuideView()
    private var spaceConstraintForPullGuideViewVisibility: NSLayoutConstraint!
    private let fakeBackgroundView = UIView()
    private let titleInputField = UITextField()
    private let underLineView = UIView()
    
    private let previewView = LinkPreviewView()
    private let previewShimmerView = PreviewShimmerView()
    
    private let attributeStackView = UIStackView()
    private let collectionPathView = CollectionPathView()
    private let priorityLabelView = KeyAndLabeledValueView()
    private let categoriesLabelView = KeyAndLabeledValueView()
    private let remindLabelView = KeyAndLabeledValueView()
    private let addPriorityButton = UIButton()
    private let addCategoryButton = UIButton()
    private let addRemindButton = UIButton()
    
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
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard self.isBeingDismissed else { return }
        self.viewModel.notifyDidDismissed()
    }
}

// MARK: - bind

extension EditLinkItemViewController {
    
    private func bind() {
        
        self.setupInitialAttributeIfPossible()
        
        self.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.rewind()
            })
            .disposed(by: self.disposeBag)
        
        self.titleInputField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.enterCustomName(text)
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
        
        self.viewModel.priority
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] priority in
                self?.updatePriority(priority)
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
        
        self.viewModel.selectedParentCollectionName
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] name in
                self?.updateParentCollectionSection(name)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.collectionPathView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.changeCollection()
            })
            .disposed(by: self.disposeBag)
        
        let editPriorityTrigger = Observable.merge(
            self.addPriorityButton.rx.throttleTap(),
            self.priorityLabelView.rx.addTapgestureRecognizer().map { _ in },
            self.priorityLabelView.rightButton.rx.throttleTap()
        )
        editPriorityTrigger
            .subscribe(onNext: { [weak self] in
                self?.viewModel.editPriority()
            })
            .disposed(by: self.disposeBag)
        
        let editCategoryTrigger = Observable.merge(
            self.addCategoryButton.rx.throttleTap(),
            self.categoriesLabelView.rx.addTapgestureRecognizer().map { _ in },
            self.categoriesLabelView.rightButton.rx.throttleTap()
        )
        editCategoryTrigger
            .subscribe(onNext: { [weak self] in
                self?.viewModel.editCategory()
            })
            .disposed(by: self.disposeBag)
        
        let editRemindTrigger = Observable.merge(
            self.addRemindButton.rx.throttleTap(),
            self.remindLabelView.rx.addTapgestureRecognizer().map { _ in },
            self.remindLabelView.rightButton.rx.throttleTap()
        )
        editRemindTrigger
            .subscribe(onNext: { [weak self] in
                self?.viewModel.editRemind()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSave()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isProcessing
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isLoading)
            .disposed(by: self.disposeBag)
    }
    
    private func setupInitialAttributeIfPossible() {
        guard let link = self.viewModel.editcaseReadLink else { return }
        self.fakeBackgroundView.isHidden = false
        self.titleInputField.text = link.customName
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
    
    private func updatePriority(_ newValue: ReadPriority?) {
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
    
    private func updateParentCollectionSection(_ name: String) {
        self.collectionPathView.isHidden.then {
            self.collectionPathView.isHidden = false
        }
        self.collectionPathView.nameLabel.text = name
    }
}

// MARK: - setup presenting

extension EditLinkItemViewController: Presenting {
    
    
    public func setupLayout() {
        
        let button = UIBarButtonItem(title: "< Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = button
        
        self.view.addSubview(fakeBackgroundView)
        fakeBackgroundView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 20)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        confirmButton.setupLayout()
        
        self.view.addSubview(attributeStackView)
        attributeStackView.autoLayout.active(with: self.view) {
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
        
        self.view.addSubview(pullGuideView)
        pullGuideView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: titleInputField.topAnchor, constant: -20)
        }
        pullGuideView.setupLayout()
        
        let spacing = Metric.topSpacingForPullGuideVisible(self.viewModel.hidePullGuideView == false)
        self.spaceConstraintForPullGuideViewVisibility = fakeBackgroundView
            .topAnchor.constraint(equalTo: pullGuideView.topAnchor, constant: spacing)
        self.spaceConstraintForPullGuideViewVisibility.isActive = true
    }
    
    public func setupStyling() {
        
        confirmButton.setupStyling()
        confirmButton.isEnabled = false
        
        self.pullGuideView.setupStyling()
        self.pullGuideView.isHidden = self.viewModel.hidePullGuideView
        
        self.fakeBackgroundView.backgroundColor = self.uiContext.colors.appBackground
        self.fakeBackgroundView.layer.cornerRadius = 10
        self.fakeBackgroundView.clipsToBounds = true
        
        self.collectionPathView.setupStyling()
        self.collectionPathView.isHidden = true
        
        self.priorityLabelView.isHidden = true
        self.categoriesLabelView.isHidden = true
        self.remindLabelView.isHidden = true
        self.addPriorityButton.isHidden = false
        self.addCategoryButton.isHidden = false
        self.addCategoryButton.isHidden = false
        
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
        
        self.previewView.setupStyling()
        self.previewView.isHidden = true
        self.previewShimmerView.setupStyling()
        self.previewShimmerView.isHidden = false
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        _ = self.titleInputField
            |> \.font .~ self.uiContext.fonts.get(16, weight: .medium)
            |> \.placeholder .~ pure("Enter a Custom name".localized)
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
    }
    
    
    public func setupUIForShareExtension() {
        
        self.rx.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.fakeBackgroundView.isHidden = false
                self.spaceConstraintForPullGuideViewVisibility.constant = Metric.topSpacingForPullGuideVisible(true)
                self.pullGuideView.isHidden = false
            })
            .disposed(by: self.disposeBag)
    }
}

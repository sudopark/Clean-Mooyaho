//
//  AddReadLinkViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - AddReadLinkViewController

public final class AddReadLinkViewController: BaseViewController, AddReadLinkScene {
    
    let viewModel: AddReadLinkViewModel
    
    private let bottomSlideMenuView = BaseBottomSlideMenuView()
    private let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    
    private let urlInputView = SingleLineInputView()
    
    private let previewSectionView = UIStackView()
    private let thumbnailImageView = UIImageView()
    private let previewcontnetStackView = UIStackView()
    private let previewTitleView = UIView()
    private let previewIconView = UIImageView()
    private let previewTitleLabel = UILabel()
    private let previewDescriptionLabel = UILabel()
    
    private let confirmButton = ConfirmButton()
    
    public init(viewModel: AddReadLinkViewModel) {
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

extension AddReadLinkViewController {
    
    private func bind() {
        
        self.viewModel.isLoadingPreview
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isLoading in
                self?.urlInputView.updateIsLoading(isLoading)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.enteredLinkPreview
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                self?.updatePreview(preview)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isSavingLinkItem
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isSaving in
                self?.confirmButton.isEnabled = isSaving == false
            })
            .disposed(by: self.disposeBag)
        
        let enteredText = self.urlInputView.rx.text.share()
        enteredText
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.enterURL(text)
            })
            .disposed(by: self.disposeBag)
        
        enteredText
            .debounce(.milliseconds(1_500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.enterURLFinished()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.saveLink()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updatePreview(_ preview: EnteredLinkPreview) {
        switch preview {
        case .notExist:
            self.previewSectionView.isHidden = true
            self.previewIconView.cancelSetupThumbnail()
            self.thumbnailImageView.cancelSetupThumbnail()
            
        case let .exist(preview):
            self.previewSectionView.isHidden = false
            self.previewIconView.cancelSetupThumbnail()
            self.thumbnailImageView.cancelSetupThumbnail()
            self.previewTitleLabel.text = preview.title ?? "Unknown".localized
            preview.iconURL.whenExists {
                self.previewIconView.setupThumbnail($0)
            }
            preview.mainImageURL.whenExists {
                self.thumbnailImageView.setupThumbnail($0)
            }
            previewDescriptionLabel.text = preview.description ?? "no preview"
        }
    }
}

// MARK: - setup presenting

extension AddReadLinkViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        bottomSlideMenuView.containerView.addSubview(contentStackView)
        contentStackView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        
        contentStackView.addArrangedSubview(urlInputView)
        urlInputView.setupLayout()
        
        previewSectionView.axis = .horizontal
        previewSectionView.distribution = .fill
        contentStackView.addArrangedSubview(previewSectionView)
        
        previewSectionView.addArrangedSubview(thumbnailImageView)
        thumbnailImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 50)
            $0.heightAnchor.constraint(equalToConstant: 50)
        }
        
        previewcontnetStackView.axis = .vertical
        previewcontnetStackView.distribution = .fill
        previewcontnetStackView.addArrangedSubview(previewTitleView)
        previewTitleView.addSubview(previewIconView)
        previewIconView.autoLayout.active(with: previewTitleView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 4)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        previewTitleView.addSubview(previewTitleLabel)
        previewTitleLabel.autoLayout.active(with: previewTitleView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.leadingAnchor.constraint(equalTo: previewIconView.trailingAnchor, constant: 4)
        }
        previewTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        previewcontnetStackView.addArrangedSubview(previewDescriptionLabel)
        
        bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        confirmButton.autoLayout.active {
            $0.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 12)
        }
    }
    
    public func setupStyling() {
        
        bottomSlideMenuView.setupStyling()
        
        self.titleLabel.decorate(self.uiContext.decorating.title)
        self.titleLabel.text = "Add Read Link"
        
        self.urlInputView.setupStyling()
        self.urlInputView.placeHolderLabel.text = "Enter an URL"
        
        self.previewTitleLabel.font = self.uiContext.fonts.get(14, weight: .medium)
        self.previewTitleLabel.textColor = self.uiContext.colors.text
        self.previewTitleLabel.numberOfLines = 1
        
        self.previewDescriptionLabel.decorate(self.uiContext.decorating.placeHolder)
        self.previewDescriptionLabel.numberOfLines = 3
        self.previewSectionView.isHidden = true
        
        self.confirmButton.setupStyling()
    }
}

//
//  EditReadRemindViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting

// MARK: - EditReadRemindViewController

public final class EditReadRemindViewController: BaseViewController, EditReadRemindScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    let titleLabel = UILabel()
    let clearButton = UIButton()
    let datePicker = UIDatePicker()
    let confirmButton = ConfirmButton()
    let viewModel: EditReadRemindViewModel
    
    public init(viewModel: EditReadRemindViewModel) {
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
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - bind

extension EditReadRemindViewController {
    
    private func bind() {
        
        self.clearButton.isHidden = self.viewModel.showClearButton == false
        
        viewModel.initialDate
            .asDriver(onErrorDriveWith: .never())
            .drive(self.datePicker.rx.date)
            .disposed(by: self.disposeBag)
        
        viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        viewModel.confirmButtonTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.confirmButton.setTitle(title, for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        self.datePicker.rx.date
            .subscribe(onNext: { [weak self] date in
                self?.viewModel.selectDate(date)
            })
            .disposed(by: self.disposeBag)
        
        self.clearButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.clearSelect()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelectRemindTime()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension EditReadRemindViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        bottomSlideMenuView.containerView.addSubview(self.confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        
        bottomSlideMenuView.containerView.addSubview(datePicker)
        datePicker.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16)
        }

        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
        }
        
        bottomSlideMenuView.containerView.addSubview(clearButton)
        clearButton.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ pure("Select a remind time".localized)
        
        self.clearButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.clearButton.setTitle("Clear".localized, for: .normal)
        
        self.datePicker.preferredDatePickerStyle = .inline
        self.datePicker.datePickerMode = .dateAndTime
        self.datePicker.minimumDate = Date()
        
        
        self.confirmButton.setupStyling()
    }
}

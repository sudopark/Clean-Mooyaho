//
//  EnterHoorayImageViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EnterHoorayImageViewController

public final class EnterHoorayImageViewController: BaseViewController, EnterHoorayImageScene {
    
    let viewModel: EnterHoorayImageViewModel
    
    let titleLabel = UILabel()
    let imageView = UIImageView()
    let imageAddButton = UIButton()
    let toolbar = HoorayActionToolbar()
    
    public init(viewModel: EnterHoorayImageViewModel) {
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

extension EnterHoorayImageViewController {
    
    private func bind() {
        
        self.imageAddButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.selectImage()
            })
            .disposed(by: self.disposeBag)
        
        self.toolbar.skipButton?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.skipInput()
            })
            .disposed(by: self.disposeBag)
        
        self.toolbar.nextButton?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.goNextInputStage()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension EnterHoorayImageViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 16)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        
        self.view.addSubview(toolbar)
        toolbar.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
        }
        self.toolbar.showSkip = true
        toolbar.setupLayout()
        
        self.view.addSubview(imageView)
        imageView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16)
            $0.bottomAnchor.constraint(equalTo: self.toolbar.topAnchor, constant: -16)
        }
        
        self.view.addSubview(imageAddButton)
        imageAddButton.autoLayout.active(with: imageView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 40)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
    }
    
    public func setupStyling() {
        
        self.imageAddButton.backgroundColor = .red
        
        self.imageView.layer.cornerRadius = 5
        self.imageView.clipsToBounds = true
        
        self.toolbar.setupStyling()
    }
}

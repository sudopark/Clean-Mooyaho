//
//  MakeHoorayViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - MakeHoorayViewController

public final class MakeHoorayViewController: BaseViewController, MakeHoorayScene {
    
    let viewModel: MakeHoorayViewModel
    let makeView = MakeHoorayView()
    
    public init(viewModel: MakeHoorayViewModel) {
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

extension MakeHoorayViewController {
    
    private func bind() {
        
        self.disposeBag.insert {
            
            self.makeView.imageInputButton.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    // TODO: route to image selection
                })
            
            self.makeView.messageInput.rx.text.orEmpty
                .subscribe(onNext: { [weak self] text in
                    self?.viewModel.enterHooray(message: text)
                    // TODO: update placeHolder isHidden
                    // TODO: update count label
                })
            
            self.makeView.placeInputButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.viewModel.requestSelectPlace()
                })
            
            self.makeView.publishButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    let tags = self.makeView.tagInputView.getAllTags().map{ $0.text }
                    self.viewModel.requestPublishNewHooray(with: tags)
                })
            
            self.view.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    self?.view.endEditing(true)
                })
        }
        
        self.disposeBag.insert {
            
            self.viewModel.memberProfileImage
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] source in
                    self?.makeView.profileImageView.setupImage(using: source)
                })
            
            self.viewModel.hoorayKeyword
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] keyword in
                    self?.makeView.keywordLabel.text = keyword
                })
            
            self.viewModel.isPublishable
                .asDriver(onErrorDriveWith: .never())
                .drive(self.makeView.publishButton.rx.isEnabled)
            
            self.viewModel.isPublishing
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] isPublishing in
                    self?.makeView.publishButton.updateIsLoading(isPublishing)
                })
        }
    }
    
    private func bindKeyboadShowing() {
        
    }
}

// MARK: - setup presenting

extension MakeHoorayViewController: Presenting, UITextViewDelegate {
    
    public func setupLayout() {
        
        self.view.addSubview(makeView)
        makeView.autoLayout.activeFill(self.view, withSafeArea: true)
        makeView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        makeView.setupStyling()
    }
    
    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // TODO: limit input
        return true
    }
}

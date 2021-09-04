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
            
            self.makeView.inputImageView.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.requestEnterImage()
                })
            
            self.makeView.messageTextView.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.requestEnterMessage()
                })
            
            self.makeView.tagInputSectionView.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.requestEnterTags()
                })
            
            self.makeView.placeInputSectionView.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.requestSelectPlace()
                })
            
            self.makeView.publishButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.requestPublishNewHooray()
                })
            
            self.view.rx.addTapgestureRecognizer()
                .subscribe(onNext: { [weak self] _ in
                    self?.view.endEditing(true)
                })
            
            self.rx.viewDidLayoutSubviews.take(1)
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.showUp()
                })
        }
        
        self.disposeBag.insert {
            
            self.viewModel.hoorayKeyword
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] keyword in
                    self?.updateHoorayKeyword(keyword.text)
                })
            
            self.viewModel.selectedImagePath
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] path in
                    self?.updateInputImage(path)
                })
            
            self.viewModel.enteredMessage
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] message in
                    self?.updateInputMessage(message)
                })
            
            self.viewModel.enteredTags
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] tags in
                    self?.updateHoorayTags(tags)
                })
            
            self.viewModel.selectedPlaceName
                .asDriver(onErrorDriveWith: .never())
                .drive(onNext: { [weak self] name in
                    self?.updateSelectedPlace(name)
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
}


// MARK: - update view

extension MakeHoorayViewController {
    
    private func updateInputImage(_ imagePath: String?) {
            
        if let path = imagePath {
            self.makeView.imageInputButton.isHidden = true
            self.makeView.inputImageView.setupThumbnail(path)
        } else {
            self.makeView.inputImageView.cancelSetupThumbnail()
            self.makeView.imageInputButton.isHidden = false
        }
    }
    
    private func updateInputMessage(_ text: String?) {
        self.makeView.messageTextView.text = text
        self.makeView.placeHolderLabel.isHidden = (text?.isEmpty ?? true) == false
    }
    
    private func updateHoorayKeyword(_ text: String) {
        self.makeView.keywordInputSectionView.innerView.attributedText = Attribute
            .keyAndValue("Hooray phrase", text)
    }
    
    private func updateHoorayTags(_ tags: [String]) {
        self.makeView.tagInputSectionView.innerView.attributedText = tags.isEmpty
            ? Attribute.tagPlaceHolder : Attribute.tagAttributeText(for: tags)
    }
    
    private func updateSelectedPlace(_ placeName: String?) {
        if let name = placeName, name.isNotEmpty {
            self.makeView.placeInputSectionView.innerView.attributedText = Attribute
                .keyAndValue("Place", name)
        } else {
            self.makeView.placeInputSectionView.innerView.attributedText = "Select a place(Recommanded)"
                .with(attribute: Attribute.placeHolder)
        }
    }
}

// MARK: - setup presenting

extension MakeHoorayViewController: Presenting, UITextViewDelegate {
    
    public func setupLayout() {
        
        self.view.addSubview(makeView)
        makeView.autoLayout.fill(self.view, withSafeArea: true)
        makeView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        makeView.setupStyling()
    }
}

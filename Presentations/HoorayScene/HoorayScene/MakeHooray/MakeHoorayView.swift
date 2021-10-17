//
//  MakeHoorayView.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit

import CommonPresenting


// MARK: - MakeHoorayView

final class MakeHoorayView: BaseUIView {
    
    let titleLabel = UILabel()
    let imageInputButton = UIImageView()
    let inputImageView = UIImageView()
    let messageTextView = UITextView()
    let placeHolderLabel = UILabel()
    let keywordInputSectionView = InfoSectionView<UILabel>()
    let tagInputSectionView = InfoSectionView<UILabel>()
    let placeInputSectionView = InfoSectionView<UILabel>()
    let suggestPlaceCollectionView = UICollectionView(frame: .zero,
                                                      collectionViewLayout: .init())
    let blurView = UIView()
    let publishButton = LoadingButton()
}

extension MakeHoorayView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(publishButton)
        publishButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        }
        self.publishButton.setupLayout()

        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        
        self.addSubview(inputImageView)
        inputImageView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 65)
            $0.heightAnchor.constraint(equalToConstant: 65)
        }
        
        self.addSubview(imageInputButton)
        imageInputButton.autoLayout.active(with: inputImageView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 18)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        }
        
        self.addSubview(messageTextView)
        messageTextView.autoLayout.active(with: inputImageView) {
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 14)
        }
        
        self.addSubview(placeHolderLabel)
        placeHolderLabel.autoLayout.active(with: messageTextView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: inputImageView.topAnchor, constant: 4)
        }
        
        let underLineView = UIView()
        self.addSubview(underLineView)
        underLineView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 6)
        }
        underLineView.backgroundColor = .groupTableViewBackground
        
        self.addSubview(keywordInputSectionView)
        keywordInputSectionView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: underLineView.bottomAnchor)
        }
        keywordInputSectionView.setupLayout()
        
        self.addSubview(tagInputSectionView)
        tagInputSectionView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: keywordInputSectionView.bottomAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        tagInputSectionView.setupLayout()
        tagInputSectionView.innerView.autoLayout.active {
            $0.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        }
        
        self.addSubview(placeInputSectionView)
        placeInputSectionView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: tagInputSectionView.bottomAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        placeInputSectionView.setupLayout()
        
        self.addSubview(suggestPlaceCollectionView)
        suggestPlaceCollectionView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: placeInputSectionView.bottomAnchor, constant: 4)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 25)
        }
    }
    
    func setupStyling() {
        
        self.titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.text = "New Hooray"
        
        self.inputImageView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.inputImageView.layer.cornerRadius = 5
        self.inputImageView.clipsToBounds = true
        self.inputImageView.isUserInteractionEnabled = true
        
        self.imageInputButton.image = UIImage(systemName: "plus")
        self.imageInputButton.isUserInteractionEnabled = false
        
        self.messageTextView.textColor = self.uiContext.colors.text
        self.messageTextView.isEditable = false
        self.messageTextView.font = .systemFont(ofSize: 14)
        
        self.placeHolderLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.4)
        self.placeHolderLabel.font = .systemFont(ofSize: 14)
        self.placeHolderLabel.text = "Enter a message...".localized
        self.placeHolderLabel.isHidden = false

        self.keywordInputSectionView.setupStyling()
        self.keywordInputSectionView.innerView.font = .systemFont(ofSize: 14, weight: .medium)
        self.keywordInputSectionView.innerView.attributedText = Attribute
            .keyAndValue("Hooray phrase", nil)
        self.keywordInputSectionView.arrowImageView.isHidden = true
        
        self.tagInputSectionView.setupStyling()
        
        self.placeInputSectionView.setupStyling()
        self.placeInputSectionView.innerView.textColor = self.uiContext.colors.text
        self.placeInputSectionView.innerView.numberOfLines = 1
        self.placeInputSectionView.innerView.font = .systemFont(ofSize: 14, weight: .medium)
        self.placeInputSectionView.innerView.lineBreakMode = .byTruncatingTail
        self.placeInputSectionView.underLineView.isHidden = true
        
        self.suggestPlaceCollectionView.backgroundColor = .clear
        
        self.publishButton.backgroundColor = UIColor.systemBlue
        self.publishButton.title = "Publish"
        self.publishButton.setupStyling()
        self.publishButton.layer.cornerRadius = 4
        self.publishButton.clipsToBounds = true
    }
}

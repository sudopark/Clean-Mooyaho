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
    
    let scrollView = UIScrollView()
    let scrollContentView = UIView()
    let imageInputButton = UIImageView()
    let inputImageView = UIImageView()
    let profileImageView: IntegratedImageView = .init()
    let keywordLabel = UILabel()
    let messageLabel = UILabel()
    let tagInputView = TextTagInputField()
    let placeIcon = UIImageView()
    let placeInputButton = UIButton(type: .system)
    let publishButton = LoadingButton()
}

extension MakeHoorayView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(publishButton)
        publishButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
        }

        self.publishButton.setupLayout()
        
        self.addSubview(scrollView)
        scrollView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            $0.topAnchor.constraint(equalTo: self.topAnchor)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: self.publishButton.topAnchor, constant: -16)
        }
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.autoLayout.activeFill(scrollView)
        scrollContentView.autoLayout.active(with: scrollView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor)
        }
        
        scrollContentView.addSubview(inputImageView)
        inputImageView.autoLayout.active(with: scrollContentView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 80)
            $0.heightAnchor.constraint(equalToConstant: 80)
        }
        
        scrollContentView.addSubview(imageInputButton)
        imageInputButton.autoLayout.active(with: inputImageView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.85)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        }
        
        scrollContentView.addSubview(profileImageView)
        profileImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 40)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.leadingAnchor.constraint(equalTo: inputImageView.trailingAnchor, constant: 16)
            $0.topAnchor.constraint(equalTo: inputImageView.topAnchor)
        }
        
        scrollContentView.addSubview(keywordLabel)
        keywordLabel.autoLayout.active(with: profileImageView) {
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 8)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -16)
        }
        
        scrollContentView.addSubview(messageLabel)
        messageLabel.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor)
            $0.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -20)
        }
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        
        scrollContentView.addSubview(tagInputView)
        tagInputView.autoLayout.active {
            $0.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16)
            $0.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20)
        }
        tagInputView.setupLayout()
        
        scrollContentView.addSubview(placeIcon)
        placeIcon.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 40)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.topAnchor.constraint(greaterThanOrEqualTo: tagInputView.bottomAnchor, constant: 16)
            $0.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor, constant: -20)
        }
        
        scrollContentView.addSubview(placeInputButton)
        placeInputButton.autoLayout.active(with: placeIcon) {
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -20)
        }
    }
    
    func setupStyling() {
        
        self.scrollView.backgroundColor = .clear
        self.scrollContentView.backgroundColor = .clear
        
        self.inputImageView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.inputImageView.layer.cornerRadius = 5
        self.inputImageView.clipsToBounds = true
        
        self.profileImageView.layer.cornerRadius = 20
        self.profileImageView.clipsToBounds = true
        
        self.keywordLabel.textColor = self.uiContext.colors.text
        self.messageLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.8)

        self.tagInputView.placeHolder = "Enter a tag"
        self.tagInputView.setupStyling()
        self.tagInputView.isEnabled = false
        
        self.placeIcon.backgroundColor = .red
        self.placeInputButton.setTitle("Select a place", for: .normal)
        
        self.publishButton.backgroundColor = UIColor.systemBlue
        self.publishButton.title = "Publish"
        self.publishButton.setupStyling()
    }
}

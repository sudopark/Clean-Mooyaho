//
//  InputTextView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/12.
//

import UIKit

import RxSwift
import RxCocoa


public final class InputTextView: BaseUIView {
    
    public let stackView = UIStackView()
    public let singleLineTextField = UITextField()
    public let placeHolderLabel = UILabel()
    public let textInputView = UITextView()
    
    var isSingleLine = false
    private var multiLineInputHeightConstraint: NSLayoutConstraint!
    
    public var text: String? {
        get {
            return self.isSingleLine ? self.singleLineTextField.text : self.textInputView.text
        }
        set {
            if self.isSingleLine {
                self.singleLineTextField.text = newValue
            } else {
                self.textInputView.text = newValue
            }
        }
    }
    
    public var maxCharCount: Int?
}

extension InputTextView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(stackView)
        stackView.autoLayout.fill(self)
        
        self.stackView.addArrangedSubview(singleLineTextField)
        
        self.stackView.addArrangedSubview(textInputView)
        self.multiLineInputHeightConstraint = textInputView.autoLayout.make{ $0.heightAnchor.constraint(equalToConstant: 0) }.first
        self.multiLineInputHeightConstraint.isActive = true
        
        self.addSubview(placeHolderLabel)
        placeHolderLabel.autoLayout.active(with: stackView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 4)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -4)
        }
    }
    
    public func setupStyling() {
        
        self.stackView.axis = .vertical
        self.stackView.backgroundColor = .clear
        self.singleLineTextField.backgroundColor = .clear
        self.textInputView.backgroundColor = .clear
        
        self.singleLineTextField.autocorrectionType = .no
        self.singleLineTextField.autocapitalizationType = .none
        self.textInputView.autocorrectionType = .no
        self.textInputView.autocapitalizationType = .none
        
        self.singleLineTextField.delegate = self
        self.textInputView.delegate = self
        
        self.backgroundColor = UIColor.from(hex: "#fdfdfd")
    }
    
    public func setupSingleLineStyling() {
        self.isSingleLine = true
        self.setupStyling()
        self.textInputView.isHidden = true
        self.placeHolderLabel.isHidden = true
        self.singleLineTextField.isHidden = false
    }
    
    public func setupMultilineStyling(_ height: CGFloat) {
        self.isSingleLine = false
        self.setupStyling()
        self.singleLineTextField.isHidden = true
        self.textInputView.isHidden = false
        self.placeHolderLabel.isHidden = false
        self.multiLineInputHeightConstraint.constant = height
    }
}


extension InputTextView: UITextFieldDelegate, UITextViewDelegate {
    
    public func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let max = self.maxCharCount else { return true }
        return self.limitTextLength(max: max, currentText: textField.text ?? "",
                                    shouldChangeTextIn: range, replacementText: string) {
            textField.text = $0
        }
    }
    
    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        
        guard let max = self.maxCharCount else { return true }
        return self.limitTextLength(max: max, currentText: textView.text ?? "",
                                    shouldChangeTextIn: range, replacementText: text) {
            textView.text = $0
        }
    }
    
    private func limitTextLength(max: Int,
                                 currentText: String,
                                 shouldChangeTextIn range: NSRange,
                                 replacementText text: String,
                                 editing: (String) -> Void) -> Bool {
        let totalText = (currentText as NSString).replacingCharacters(in: range, with: text)
        let numberOfText = totalText.count
        if numberOfText >= max {
            let length = max - currentText.count
            guard length != 0 else { return false }
            let newText = (currentText as NSString).replacingCharacters(in: range, with: text.substring(nsRange: NSRange(location: 0, length: length)))
            editing(newText)
        }
        return numberOfText < max
    }
}

extension Reactive where Base == InputTextView {
    
    public var text: ControlProperty<String?> {
        return base.isSingleLine ? base.singleLineTextField.rx.text
            : base.textInputView.rx.text
    }
}

//
//  SingleLineInputView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/27.
//

import UIKit

import RxSwift
import RxCocoa


public final class SingleLineInputView: BaseUIView {
    
    public let iconImageView = UIImageView()
    public let placeHolderLabel = UILabel()
    public let textField = UITextField()
    public let cleaerButton = UIButton()
    public let indicator = UIActivityIndicatorView()
    
    public func updateIsLoading(_ newValue: Bool) {
        if newValue {
            self.cleaerButton.isHidden = true
            self.indicator.startAnimating()
        } else {
            self.indicator.stopAnimating()
            self.cleaerButton.isHidden = (self.textField.text ?? "").isEmpty
        }
    }
    
    public func clearInput() {
        self.textField.text = nil
        self.cleaerButton.isHidden = true
    }
}

extension Reactive where Base == SingleLineInputView {
    
    
    public var text: Observable<String> {
        
        let updateViews: (String) -> Void = { [weak base] text in
            base?.placeHolderLabel.isHidden = text.isNotEmpty
            base?.cleaerButton.isHidden = text.isEmpty
        }
        
        return base.textField.rx.text.orEmpty
            .do(onNext: updateViews)
    }
    
    public var clear: ControlEvent<Void> {
        return base.cleaerButton.rx.tap
    }
}


extension SingleLineInputView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(iconImageView)
        iconImageView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.addSubview(cleaerButton)
        cleaerButton.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.widthAnchor.constraint(equalToConstant: 18)
            $0.heightAnchor.constraint(equalToConstant: 18)
        }
        
        self.addSubview(indicator)
        indicator.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.widthAnchor.constraint(equalToConstant: 18)
            $0.heightAnchor.constraint(equalToConstant: 18)
        }
        
        self.addSubview(textField)
        textField.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: cleaerButton.leadingAnchor, constant: -6)
            $0.topAnchor.constraint(equalTo: self.topAnchor, constant: 6)
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6)
        }
        
        self.addSubview(placeHolderLabel)
        placeHolderLabel.autoLayout.active(with: textField) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
    }
    
    public func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.lineColor
        
        self.iconImageView.image = UIImage(named: "magnifyingglass")
        self.cleaerButton.setImage(UIImage(named: "xmark.circle.fill"), for: .normal)
        self.cleaerButton.isHidden = true

        self.indicator.isHidden = true
        self.indicator.hidesWhenStopped = true
        
        self.placeHolderLabel.numberOfLines = 1
        self.placeHolderLabel.decorate(self.uiContext.decorating.placeHolder)
        
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
    }
}

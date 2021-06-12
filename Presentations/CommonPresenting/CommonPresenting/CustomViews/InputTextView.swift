//
//  InputTextView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/12.
//

import UIKit

public final class InputTextView: BaseUIView {
    
    public let placeHolderLabel = UILabel()
    public let textInputView = UITextView()
}

extension InputTextView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(textInputView)
        textInputView.autoLayout.activeFill(self)
        
        self.addSubview(placeHolderLabel)
        placeHolderLabel.autoLayout.active(with: textInputView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 4)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -4)
        }
    }
    
    public func setupStyling() {
        
        self.placeHolderLabel.numberOfLines = 1
    }
}

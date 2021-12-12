//
//  ConfrimButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/06.
//

import UIKit


public class ConfirmButton: UIButton, UIContextAccessable {
    
    public override var isEnabled: Bool {
        get {
            super.isEnabled
        }
        set {
            super.isEnabled = newValue
            self.alpha = newValue ? 1.0 : 0.5
        }
    }
}


extension ConfirmButton: Presenting {
    
    public func setupLayout() { }
    
    public func setupStyling() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = self.uiContext.colors.accentColor
        self.setTitle("Confirm", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = self.uiContext.fonts.get(16, weight: .medium)
    }
    
    public func setupLayout(_ parentView: UIView) {
        
        parentView.addSubview(self)
        self.autoLayout.active(with: parentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
    }
}

// MARK: - CancelButton

public class CancelButton: UIButton, UIContextAccessable {
    
    public override var isEnabled: Bool {
        get {
            super.isEnabled
        }
        set {
            super.isEnabled = newValue
            self.alpha = newValue ? 1.0 : 0.5
        }
    }
}

extension CancelButton: Presenting {
    
    public func setupLayout() { }
    
    public func setupStyling() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = self.uiContext.colors.appBackground
        self.setTitle("Cancel", for: .normal)
        self.setTitleColor(self.uiContext.colors.accentColor, for: .normal)
        self.layer.borderColor = self.uiContext.colors.accentColor.cgColor
        self.layer.borderWidth = 1
        self.titleLabel?.font = self.uiContext.fonts.get(16, weight: .medium)
    }
    
    public func setupLayout(_ parentView: UIView) {
        
        parentView.addSubview(self)
        self.autoLayout.active(with: parentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
    }
}

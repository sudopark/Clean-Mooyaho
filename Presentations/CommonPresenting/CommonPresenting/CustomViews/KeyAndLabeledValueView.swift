//
//  KeyAndLabeledValueView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/03.
//

import UIKit

import Prelude
import Optics


public final class KeyAndLabeledValueView: BaseUIView, Presenting {
    
    public let iconView = UIImageView()
    public let keyLabel = UILabel()
    public let labelView = ItemLabelView()
    public let rightButton = UIButton()
    
    private var labelTrailing: NSLayoutConstraint!
    
    public func updateRightButtonIsHidden(_ isHidden: Bool) {
        self.labelTrailing?.constant = isHidden ? 0 : -(15 + 4)
        self.rightButton.isHidden = isHidden
    }
    
    public func setupLayout() {
        
        self.addSubview(iconView)
        iconView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
        }
        
        self.addSubview(keyLabel)
        keyLabel.autoLayout.active(with: iconView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 8)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.addSubview(labelView)
        labelView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 100)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 6)
        }
        self.labelTrailing = labelView.autoLayout
            .make(with: self) { $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor) }.first
        self.labelTrailing.isActive = true
        self.labelView.setContentCompressionResistancePriority(.required, for: .vertical)
        labelView.setupLayout()
        
        self.addSubview(rightButton)
        rightButton.autoLayout.active(with: self) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.centerYAnchor.constraint(equalTo: keyLabel.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
    }
    
    public func setupStyling() {
        
        self.iconView.tintColor = self.uiContext.colors.descriptionText
        
        _ = self.keyLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.numberOfLines .~ 1
        
        self.labelView.font = self.uiContext.fonts.get(13, weight: .regular)
        self.labelView.setupStyling()
        
        self.rightButton.setImage(UIImage(named: "chevron.right"), for: .normal)
        self.rightButton.tintColor = self.uiContext.colors.hintText
        self.rightButton.isHidden = true
    }
}

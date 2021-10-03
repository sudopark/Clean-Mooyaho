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
    
    public func setupLayout() {
        
        self.addSubview(iconView)
        iconView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
        }
        
        self.addSubview(keyLabel)
        keyLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8)
            $0.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        }
        
        self.addSubview(labelView)
        labelView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: self.keyLabel.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 100)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        self.labelView.setContentCompressionResistancePriority(.required, for: .vertical)
        labelView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.iconView.tintColor = self.uiContext.colors.descriptionText
        
        _ = self.keyLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.numberOfLines .~ 1
        
        self.labelView.font = self.uiContext.fonts.get(13, weight: .regular)
        self.labelView.setupStyling()
    }
}

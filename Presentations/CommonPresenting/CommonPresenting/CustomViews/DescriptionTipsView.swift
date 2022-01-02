//
//  DescriptionTipsView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import Prelude
import Optics


public final class DescriptionTipsView: BaseUIView {
    
    private let stackView = UIStackView()
    
    final class TipView: BaseUIView {
        let dotLabel = UILabel()
        let descriptionLabel = UILabel()
    }
    
    public func updateTipsSpacing(_ spacing: CGFloat) {
        self.stackView.spacing = spacing
    }
    
    public func setupDescriptions(_ descriptions: [String]) {
        descriptions.forEach { description in
            let tipView = TipView()
            tipView.descriptionLabel.text = description
            self.stackView.addArrangedSubview(tipView)
            tipView.setupLayout()
            tipView.setupStyling()
            tipView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }
    }
}

extension DescriptionTipsView: Presenting {
    
    public func setupLayout() {
        self.addSubview(stackView)
        stackView.autoLayout.fill(self)
        stackView.axis = .vertical
    }
    
    public func setupStyling() {
        self.backgroundColor = .clear
    }
}

extension DescriptionTipsView.TipView: Presenting {
    
    func setupLayout() {
        self.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.addSubview(dotLabel)
        dotLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -4)
            $0.centerYAnchor.constraint(equalTo: descriptionLabel.firstBaselineAnchor, constant: -2)
            $0.widthAnchor.constraint(equalToConstant: 6)
        }
        dotLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setupStyling() {
        
        _ = dotLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.numberOfLines .~ 1
            |> \.text .~ "•"
        
        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemDescription
            |> \.numberOfLines .~ 0
            |> \.textAlignment .~ .left
    }
}

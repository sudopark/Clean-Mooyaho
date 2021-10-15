//
//  ReadItemExppandContentView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/14.
//

import UIKit

import Prelude
import Optics


// MARK: - item shrink content view

public class ReadItemShrinkContentView: BaseUIView, Presenting {
    
    public let contentStackView = UIStackView()
    public let titleAreaStackView = UIStackView()
    public let iconImageView = UIImageView()
    public let nameLabel = UILabel()
    public let addressLabel = UILabel()
    public let descriptionLabel = UILabel()
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupLayout() {
        
        self.addSubview(contentStackView)
        contentStackView.autoLayout.fill(self)
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        
        contentStackView.addArrangedSubview(titleAreaStackView)
        titleAreaStackView.axis = .horizontal
        titleAreaStackView.alignment = .center
        titleAreaStackView.spacing = 6
        
        titleAreaStackView.addArrangedSubview(iconImageView)
        iconImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        nameLabel.numberOfLines = 1
        titleAreaStackView.addArrangedSubview(nameLabel)
        nameLabel.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        addressLabel.numberOfLines = 1
        contentStackView.addArrangedSubview(addressLabel)
        addressLabel.autoLayout.active(with: contentStackView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 18)
        }
        addressLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        descriptionLabel.numberOfLines = 2
        contentStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: contentStackView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
        }
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    public func setupStyling() {
        
        _ = nameLabel
            |> self.uiContext.decorating.listItemTitle(_:)
        
        _ = addressLabel
            |> self.uiContext.decorating.listItemSubDescription(_:)
            |> \.isHidden .~ true
        
        _ = descriptionLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.isHidden .~ true
    }
}



// MARK: - item expand content view

public final class ReadItemExppandContentView: ReadItemShrinkContentView {
    
    public let priorityLabel = ItemLabelView()
    public let categoriesView = ItemLabelView()
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setupLayout() {
        super.setupLayout()
        
        self.contentStackView.addArrangedSubview(priorityLabel)
        priorityLabel.autoLayout.active(with: self.contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        priorityLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        priorityLabel.setupLayout()
        
        contentStackView.addArrangedSubview(categoriesView)
        categoriesView.autoLayout.active(with: contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        categoriesView.setContentCompressionResistancePriority(.required, for: .vertical)
        categoriesView.setupLayout()
    }
    
    public override func setupStyling() {
        
        super.setupStyling()
        
        self.priorityLabel.setupStyling()
        self.priorityLabel.isHidden = true
        
        self.categoriesView.setupStyling()
        self.categoriesView.isHidden = true
    }
}

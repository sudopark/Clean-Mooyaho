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
    public let titleAreaView = UIView()
    public let favoriteImageVIew = UIImageView()
    public let iconImageView = UIImageView()
    public let nameLabel = UILabel()
    public let addressLabel = UILabel()
    public let descriptionLabel = UILabel()
    private var nameLabelTrailing: NSLayoutConstraint!
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateFavoriteView(_ isFavorite: Bool) {
        self.favoriteImageVIew.isHidden = isFavorite == false
        self.nameLabelTrailing.constant = -(isFavorite ? 21 : 0)
    }
    
    public func setupLayout() {
        
        self.addSubview(contentStackView)
        contentStackView.autoLayout.fill(self)
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        
        contentStackView.addArrangedSubview(titleAreaView)
        titleAreaView.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        titleAreaView.addSubview(iconImageView)
        iconImageView.autoLayout.active(with: titleAreaView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        nameLabel.numberOfLines = 1
        titleAreaView.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: titleAreaView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6)
        }
        self.nameLabelTrailing = self.nameLabel.trailingAnchor
            .constraint(lessThanOrEqualTo: titleAreaView.trailingAnchor)
        self.nameLabelTrailing.isActive = true
        
        titleAreaView.addSubview(favoriteImageVIew)
        favoriteImageVIew.autoLayout.active(with: titleAreaView) {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor)
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
        
        self.iconImageView.contentMode = .scaleAspectFit
        
        _ = nameLabel
            |> self.uiContext.decorating.listItemTitle(_:)
        
        self.favoriteImageVIew.image = UIImage(systemName: "star.fill")
        self.favoriteImageVIew.tintColor = UIColor.systemYellow
        self.favoriteImageVIew.isHidden = true
        
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
    public let remindView = ItemLabelView()
    
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
        
        self.contentStackView.addArrangedSubview(remindView)
        remindView.autoLayout.active(with: contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        remindView.setContentCompressionResistancePriority(.required, for: .vertical)
        remindView.setupLayout()
    }
    
    public override func setupStyling() {
        
        super.setupStyling()
        
        self.priorityLabel.setupStyling()
        self.priorityLabel.isHidden = true
        
        self.categoriesView.setupStyling()
        self.categoriesView.isHidden = true
        
        self.remindView.setupStyling()
        self.remindView.isHidden = true
    }
}

//
//  ReadItemExppandContentView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/14.
//

import UIKit

import Prelude
import Optics

import Domain


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
        contentStackView.distribution = .fill
        
        contentStackView.addArrangedSubview(titleAreaView)
        titleAreaView.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 22)
            $0.widthAnchor.constraint(equalTo: titleAreaView.widthAnchor)
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
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 18).setupPriority(.defaultHigh)
        }
        addressLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        descriptionLabel.numberOfLines = 2
        contentStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: contentStackView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 16).setupPriority(.defaultHigh)
        }
    }
    
    public func setupStyling() {
        
        self.iconImageView.contentMode = .scaleAspectFit
        
        _ = nameLabel
            |> { self.uiContext.decorating.listItemTitle($0) }
        
        self.favoriteImageVIew.image = UIImage(systemName: "star.fill")
        self.favoriteImageVIew.tintColor = UIColor.systemYellow
        self.favoriteImageVIew.isHidden = true
        self.favoriteImageVIew.contentMode = .scaleAspectFit
        
        _ = addressLabel
            |> { self.uiContext.decorating.listItemSubDescription($0) }
            |> \.isHidden .~ true
        
        _ = descriptionLabel
            |> { self.uiContext.decorating.listItemDescription($0) }
            |> \.isHidden .~ true
    }
}


// MARK: - OwnerInfoView

public final class OwnerInfoView: BaseUIView, Presenting {
    
    public let sharedLabel = UILabel()
    public let shareMemberProfileImageView = IntegratedImageView()
    public let shareMemberNameLabel = UILabel()
    
    public func updateOwner(_ member: Member) {
        self.shareMemberNameLabel.text = member.nickName ?? "Unknown".localized
        self.shareMemberProfileImageView.cancelSetupImage()
        guard let icon = member.icon else { return }
        self.shareMemberProfileImageView.setupImage(using: icon, resize: .init(width: 15, height: 15))
    }
}

extension OwnerInfoView {
    
    public func setupLayout() {
        
        self.addSubview(shareMemberProfileImageView)
        shareMemberProfileImageView.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 18)
            $0.heightAnchor.constraint(equalToConstant: 18)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        self.shareMemberProfileImageView.setupLayout()
        
        self.addSubview(sharedLabel)
        sharedLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.centerYAnchor.constraint(equalTo: shareMemberProfileImageView.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: shareMemberProfileImageView.leadingAnchor, constant: -6)
        }
        sharedLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.addSubview(shareMemberNameLabel)
        shareMemberNameLabel.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: shareMemberProfileImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor)
        }
    }
    
    public func setupStyling() {
        
        _ = self.sharedLabel
            |> {self.uiContext.decorating.listItemDescription($0) }
            |> \.text .~ pure("shared by".localized)
            |> \.numberOfLines .~ 1
        
        self.shareMemberProfileImageView.setupStyling()
        self.shareMemberProfileImageView.layer.cornerRadius = 9
        self.shareMemberProfileImageView.clipsToBounds = true

        _ = self.shareMemberNameLabel
            |> { self.uiContext.decorating.listItemDescription($0) }
            |> \.font .~ self.uiContext.fonts.get(12, weight: .medium)
            |> \.numberOfLines .~ 1
    }
}


// MARK: - item expand content view

public final class ReadItemExppandContentView: ReadItemShrinkContentView {
    
    public let ownerInfoView = OwnerInfoView()
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
        
        self.contentStackView.addArrangedSubview(ownerInfoView)
        ownerInfoView.autoLayout.active(with: self.contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        ownerInfoView.setupLayout()
        
        self.contentStackView.addArrangedSubview(priorityLabel)
        priorityLabel.autoLayout.active(with: self.contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        }
        priorityLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentStackView.addArrangedSubview(categoriesView)
        categoriesView.autoLayout.active(with: contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        }
        categoriesView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.contentStackView.addArrangedSubview(remindView)
        remindView.autoLayout.active(with: contentStackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        }
        remindView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    public override func setupStyling() {
        
        super.setupStyling()
        
        self.ownerInfoView.setupStyling()
        self.ownerInfoView.isHidden = true
        
        self.priorityLabel.isHidden = true
        self.priorityLabel.backgroundColor = .clear
        
        self.categoriesView.isHidden = true
        self.categoriesView.backgroundColor = .clear
        
        self.remindView.isHidden = true
        self.remindView.backgroundColor = .clear
    }
}

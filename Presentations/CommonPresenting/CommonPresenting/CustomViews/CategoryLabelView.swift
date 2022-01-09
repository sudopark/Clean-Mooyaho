//
//  CategoryLabelView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/12/03.
//

import UIKit

import RxSwift

import Domain


public final class CategoryLabelView: BaseUIView, Presenting {
    
    public let nameLabel = UILabel()
    public let closeImageView = UIImageView()
    private var nameLabelTrainging: NSLayoutConstraint!

    public func setup(name: String) {
        self.nameLabel.text = name
    }
    
    public func updateCloseViewIsHidden(_ isHidden: Bool) {
        self.nameLabelTrainging.constant = isHidden ? -4 : -23
        self.closeImageView.isHidden = isHidden
    }
    
    public func setupLayout() {
        
        self.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 4)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 4)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -4)
        }
        self.nameLabelTrainging = nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4)
        self.nameLabelTrainging.isActive = true
        
        self.addSubview(closeImageView)
        closeImageView.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -4)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
    }
    
    public func setupStyling() {
        
        self.nameLabel.font = self.uiContext.fonts.get(14, weight: .regular)
        self.nameLabel.textColor = UIColor.white
        
        self.closeImageView.image = UIImage(systemName: "xmark")
        self.closeImageView.tintColor = .white
        self.closeImageView.isHidden = true
        self.closeImageView.contentMode = .scaleAspectFit
        
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
    }
}

//
//  EditLinkItemView.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/03.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


final class LinkPreviewView: BaseUIView, Presenting {
    
    private let vlineView = UIView()
    private let stackView = UIStackView()
    private let contentStackView = UIStackView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let addressLabel = UILabel()
    
    func setupLayout() {
        
        self.addSubview(vlineView)
        vlineView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.widthAnchor.constraint(equalToConstant: 2)
        }
        
        self.addSubview(stackView)
        stackView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: vlineView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        stackView.axis = .horizontal
        
        stackView.addArrangedSubview(contentStackView)
        stackView.addArrangedSubview(thumbnailImageView)
        thumbnailImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 50)
            $0.heightAnchor.constraint(equalToConstant: 50)
        }
        
        contentStackView.axis = .vertical
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(addressLabel)
    }
    
    func setupStyling() {
        vlineView.layer.cornerRadius = 1
        vlineView.clipsToBounds = true
        vlineView.backgroundColor = self.uiContext.colors.accentColor
        
        self.thumbnailImageView.backgroundColor = self.uiContext.colors.lineColor
        self.thumbnailImageView.contentMode = .scaleToFill
        
        _ = self.titleLabel
            |> self.uiContext.decorating.listSectionTitle
            |> \.numberOfLines .~ 1
        
        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemDescription
            |> \.numberOfLines .~ 2
        
        _ = self.addressLabel
            |> self.uiContext.decorating.listItemSubDescription(_:)
            |> self.uiContext.decorating.underLineText
            |> \.numberOfLines .~ 1
    }
}

final class PreviewShimmerView: BaseUIView, Presenting {
    
    private let titleShimmerView = SingleLineShimmerView()
    private let contentShimmerView = MultilineShimmerView()
    
    func setupLayout() {
        
        self.addSubview(titleShimmerView)
        titleShimmerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        titleShimmerView.setupLayout()
        
        self.addSubview(contentShimmerView)
        contentShimmerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: self.titleShimmerView.bottomAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        contentShimmerView.setupLayout()
    }
    
    func setupStyling() {
        titleShimmerView.shimmerColor = self.uiContext.colors.title.withAlphaComponent(0.3)
        titleShimmerView.setupStyling()
        
        contentShimmerView.setupStyling()
    }
    
    func startAnimation() {
        self.titleShimmerView.startAnimation()
        self.contentShimmerView.startAnimation()
    }
    
    func stopAnimation() {
        self.titleShimmerView.stopAnimation()
        self.contentShimmerView.stopAnimation()
    }
}

//
//  IntegratedSearchResultCells.swift
//  SuggestScene
//
//  Created by sudo.park on 2021/11/25.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import Domain
import CommonPresenting


final class SearchReadItemCell: BaseTableViewCell, Presenting {
    
    private let expandView = ReadItemExppandContentView()
    private let arrowImageView = UIImageView()
    private let underLineView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: SearchReadItemCellViewModel) {
        
        self.expandView.iconImageView.image = UIImage(systemName: cellViewModel.isCollection ? "folder" : "doc.text")
        
        self.expandView.nameLabel.text = cellViewModel.displayName
        
        let validDescription = cellViewModel.description.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.descriptionLabel.isHidden = validDescription == nil
        self.expandView.descriptionLabel.text = validDescription
        
        self.updateCategories(cellViewModel.categories)
    }
    
    func updateCategories(_ categories: [ItemCategory]) {
        let validCategory = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| { self.expandView.categoriesView.updateCategories($0) }
    }
}


extension SearchReadItemCell {
    
    func setupLayout() {
        self.contentView.addSubview(arrowImageView)
        arrowImageView.autoLayout.active(with: self.contentView) {
            $0.widthAnchor.constraint(equalToConstant: 8)
            $0.heightAnchor.constraint(equalToConstant: 22)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
        
        self.contentView.addSubview(expandView)
        expandView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -4)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
        }
        expandView.setupLayout()
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 0)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
    }
    
    func setupStyling() {
        self.arrowImageView.image = UIImage(systemName: "chevron.right")
        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.tintColor = self.uiContext.colors.hintText
        
        self.expandView.setupStyling()
        self.expandView.tintColor = self.uiContext.colors.secondaryTitle
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

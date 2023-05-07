//
//  ReadItemCells.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/22.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics
import ValidationSemigroup

import Domain
import CommonPresenting


// MARK: - section0: ReadCollectionAttrCell

final class ReadCollcetionAttrCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadCollectionAttrCellViewModel
    
    private let stackView = UIStackView()
    private let descriptionLabel = UILabel()
    private let priorityView = KeyAndLabeledValueView()
    private let categoryView = KeyAndLabeledValueView()
    private let remindView = KeyAndLabeledValueView()
    private let underLineView = UIView()
    
    func setupCell(_ cellViewModel: ReadCollectionAttrCellViewModel) {
        
        let validDesription = cellViewModel.collectionDescription.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.descriptionLabel.isHidden = validDesription == nil
        self.descriptionLabel.text = validDesription
        
        let priotiry = cellViewModel.priority
        self.priorityView.isHidden = priotiry == nil
        priotiry.do <| { self.priorityView.labelView.setupPriority($0) }
            
        self.updateCategories(cellViewModel.categories)
            
        let remindtime = cellViewModel.remindTime
        self.remindView.isHidden = remindtime == nil
        remindtime.do <| { self.remindView.labelView.setupRemind($0) }
    }
    
    func updateCategories(_ categories: [ItemCategory]) {
        let validCategories = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.categoryView.isHidden = validCategories == nil
        validCategories.do <| { self.categoryView.labelView.updateCategories($0) } 
    }
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        self.contentView.addSubview(stackView)
        self.stackView.autoLayout.fill(self.contentView, edges: .init(top: 0, left: 14, bottom: 9, right: 14))
        self.stackView.addArrangedSubview(self.descriptionLabel)
        self.stackView.addArrangedSubview(self.priorityView)
        self.stackView.addArrangedSubview(self.categoryView)
        self.stackView.addArrangedSubview(self.remindView)
        self.descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.descriptionLabel.autoLayout.active {
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 16)
        }
        self.priorityView.autoLayout.active(with: self.stackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        self.priorityView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.categoryView.autoLayout.active(with: self.stackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        self.remindView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.remindView.autoLayout.active(with: self.stackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        self.categoryView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.priorityView.setupLayout()
        self.categoryView.setupLayout()
        self.remindView.setupLayout()
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 14)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -14)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
    }
    
    func setupStyling() {
        
        self.stackView.axis = .vertical
        self.stackView.distribution = .fill
        self.stackView.spacing = 6
        
        self.descriptionLabel.font = self.uiContext.fonts.get(13, weight: .regular)
        self.descriptionLabel.textColor = self.uiContext.colors.descriptionText
        self.descriptionLabel.numberOfLines = 1
        
        self.priorityView.setupStyling()
        self.priorityView.iconView.image = UIImage(systemName: "arrow.up.arrow.down.square")
        self.priorityView.keyLabel.text = "Priority".localized
        
        self.categoryView.setupStyling()
        self.categoryView.iconView.image = UIImage(systemName: "line.horizontal.3.decrease.circle")
        self.categoryView.keyLabel.text = "Categories".localized
        
        self.remindView.setupStyling()
        self.remindView.iconView.image = UIImage(systemName: "alarm")
        self.remindView.keyLabel.text = "Remind".localized
        
        self.descriptionLabel.isHidden = true
        self.priorityView.isHidden = true
        self.categoryView.isHidden = true
        self.remindView.isHidden = true
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

// MARK: - section1: ReadCollectionExpandCell

typealias ReadCollectionExpandCell = DefaultReadCollectionCell

// MARK: - section2: ReadLinkExpandCell

typealias ReadLinkExpandCell = DefaultReadLinkCell


// MARK: - shrink

final class ReadItemShrinkCollectionCell: ReadItemShrinkCell {
    
    func setupCell(_ cellViewModel: ReadCollectionCellViewModel) {
        
        self.shrinkView.nameLabel.text = cellViewModel.name
        
        self.shrinkView.updateFavoriteView(cellViewModel.isFavorite)
        
        let validDescription = cellViewModel.collectionDescription.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.shrinkView.descriptionLabel.isHidden = validDescription == nil
        self.shrinkView.descriptionLabel.text = validDescription
    }
    
    override func setupStyling() {
        super.setupStyling()
        self.shrinkView.iconImageView.image = UIImage(systemName: "folder")
        self.shrinkView.iconImageView.tintColor = self.uiContext.colors.secondaryTitle
    }
}

final class ReadItemShrinkLinkCell: ReadItemShrinkCell {
    
    func setupCell(_ cellViewModel: ReadLinkCellViewModel) {
        self.updateTitle(cellViewModel.customName)
        self.shrinkView.updateFavoriteView(cellViewModel.isFavorite)
        self.shrinkView.addressLabel.text = cellViewModel.linkUrl
    }
    
    func bindPreview(_ source: Observable<LinkPreview>, customTitle: String?) {
        
        source
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                guard let self = self else { return }
                (customTitle?.isEmpty ?? true).then <| { self.updateTitle(preview.title) }
                self.updateDescription(preview.description)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateTitle(_ title: String?) {
        let title = title.flatMap{ $0.isNotEmpty ? $0 : nil } ?? "No preview title".localized
        self.shrinkView.nameLabel.text = title
    }
    
    private func updateDescription(_ description: String?) {
        let description = description.flatMap { $0.isNotEmpty ? $0 : nil }
        self.shrinkView.descriptionLabel.isHidden = description == nil
        self.shrinkView.descriptionLabel.text = description
    }
    
    override func setupStyling() {
        super.setupStyling()
        self.shrinkView.iconImageView.image = UIImage(systemName: "doc.text")
        self.shrinkView.iconImageView.tintColor = self.uiContext.colors.secondaryTitle
    }
}

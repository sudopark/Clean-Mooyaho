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


// MARK: - ReadCollectionTtileHeaderView

final class ReadCollectionTtileHeaderView: BaseUIView, Presenting {
    
    private let titleLabel = UILabel()
    
    func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    func setupLayout() {
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 13)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
    }
    
    func setupStyling() {
        _ = self.titleLabel |> self.uiContext.decorating.header
    }
}


// MARK: - ReadCollectionSectionHeaderView

final class ReadCollectionSectionHeaderView: BaseTableViewSectionHeaderFooterView, Presenting {
    
    private let titleLabel = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    func setupLayout() {
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 4)
        }
    }
    
    func setupStyling() {
        _ = self.titleLabel |> self.uiContext.decorating.listSectionTitle(_:)
    }
}


// MARK: - ReadItemCells

public protocol ReadItemCells: BaseTableViewCell {
    
    associatedtype CellViewModel: ReadItemCellViewModel
    
    func setupCell(_ cellViewModel: CellViewModel)
    
    func updateCategories(_ categories: [ItemCategory])
}


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
        priotiry.do <| priorityView.labelView.setupPriority
            
        self.updateCategories(cellViewModel.categories)
            
        let remindtime = cellViewModel.remindTime
        self.remindView.isHidden = remindtime == nil
        remindtime.do <| remindView.labelView.setupRemind(_:)
    }
    
    func updateCategories(_ categories: [ItemCategory]) {
        let validCategories = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.categoryView.isHidden = validCategories == nil
        validCategories.do <| categoryView.labelView.updateCategories
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

final class ReadCollectionExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadCollectionCellViewModel
    
    private let expandView = ReadItemExppandContentView()
    private let arrowImageView = UIImageView()
    private let underLineView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: ReadCollectionCellViewModel) {
        
        self.expandView.nameLabel.text = cellViewModel.name
        
        let validDescription = cellViewModel.collectionDescription.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.descriptionLabel.isHidden = validDescription == nil
        self.expandView.descriptionLabel.text = validDescription
        
        let priority = cellViewModel.priority
        self.expandView.priorityLabel.isHidden = priority == nil
        priority.do <| self.expandView.priorityLabel.setupPriority
            
        self.updateCategories(cellViewModel.categories)
            
        let remindtime = cellViewModel.remindTime
        self.expandView.remindView.isHidden = remindtime == nil
        remindtime.do <| expandView.remindView.setupRemindWithIcon(_:)
    }
    
    func updateCategories(_ categories: [ItemCategory]) {
        let validCategory = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| self.expandView.categoriesView.updateCategories(_:)
    }
    
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
        self.expandView.iconImageView.image = UIImage(systemName: "folder")
        self.expandView.tintColor = self.uiContext.colors.secondaryTitle
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

// MARK: - section2: ReadLinkExpandCell

final class ReadLinkExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadLinkCellViewModel
    
    private let expandView = ReadItemExppandContentView()
    private let thumbNailView = UIImageView()
    private let underLineView = UIView()
    private var expandViewTrailing: NSLayoutConstraint!
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        expandViewTrailing.constant = -12
        self.thumbNailView.cancelSetupThumbnail()
    }
    
    func setupCell(_ cellViewModel: ReadLinkCellViewModel) {
        
        self.updateTitle(cellViewModel.customName)
        self.updateIsRed(cellViewModel.isRed)
        self.expandView.addressLabel.text = cellViewModel.linkUrl
        
        let priority = cellViewModel.priority
        self.expandView.priorityLabel.isHidden = priority == nil
        priority.do <| self.expandView.priorityLabel.setupPriority
                
        self.updateCategories(cellViewModel.categories)
            
        let remindtime = cellViewModel.remindTime
        self.expandView.remindView.isHidden = remindtime == nil
        remindtime.do <| expandView.remindView.setupRemindWithIcon(_:)
    }
    
    func updateIsRed(_ isRed: Bool) {
        let imageName = isRed ? "checkmark.circle.fill" : "folder"
        let imagetintColor = isRed ? UIColor.systemGreen : self.uiContext.colors.secondaryTitle
        self.expandView.iconImageView.image = UIImage(systemName: imageName)
        self.expandView.iconImageView.tintColor = imagetintColor
        
        self.expandView.nameLabel.alpha = isRed ? 0.4 : 1.0
    }
    
    func updateCategories(_ categories: [ItemCategory]) {
        let validCategory = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| self.expandView.categoriesView.updateCategories(_:)
    }
    
    func bindPreview(_ source: Observable<LinkPreview>, customTitle: String?) {
        
        source.asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                guard let self = self else { return }
                self.updateThumbnailIfPossible(with: preview.mainImageURL)
                (customTitle?.isEmpty ?? true).then <| { self.updateTitle(preview.title) }
                self.updateDescription(preview.description)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateThumbnailIfPossible(with url: String?) {
        thumbNailView.cancelSetupThumbnail()
        thumbNailView.isHidden = true
        expandViewTrailing.constant = -12
        guard let url = url else { return }
        self.thumbNailView.setupThumbnail(url, resize: .init(width: 65, height: 65), completed:  { [weak self] result in
            guard case .success = result else { return }
            self?.thumbNailView.isHidden = false
            self?.expandViewTrailing.constant = -12 - 4 - 65
        })
    }
    
    private func updateTitle(_ title: String?) {
        let title = title.flatMap{ $0.isNotEmpty ? $0 : nil } ?? "Fail to load preview".localized
        self.expandView.nameLabel.text = title
    }
    
    private func updateDescription(_ description: String?) {
        let description = description.flatMap { $0.isNotEmpty ? $0 : nil }
        self.expandView.descriptionLabel.isHidden = description == nil
        self.expandView.descriptionLabel.text = description
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(expandView)
        expandView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
        }
        self.expandViewTrailing = expandView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12)
        self.expandViewTrailing.isActive = true
        expandView.setupLayout()
        
        self.contentView.addSubview(thumbNailView)
        thumbNailView.autoLayout.active(with: self.contentView) {
            $0.widthAnchor.constraint(equalToConstant: 65)
            $0.heightAnchor.constraint(equalToConstant: 65)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.topAnchor.constraint(greaterThanOrEqualTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: $1.bottomAnchor, constant: -8)
        }
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 0)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
    }
    
    func setupStyling() {
    
        _ = self.thumbNailView
            |> flip(curry(self.uiContext.decorating.roundedThumbnail(_:radius:)))(5)
            |> \.isHidden .~ true
        
        self.expandView.setupStyling()
        self.expandView.iconImageView.image = UIImage(systemName: "doc.text")
        self.expandView.tintColor = self.uiContext.colors.secondaryTitle
        
        self.expandView.addressLabel.isHidden = false
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}


// MARK: - shrink

class ReadItemShrinkCell: BaseTableViewCell, Presenting {
    
    let shrinkView = ReadItemShrinkContentView()
    let underLineView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(shrinkView)
        shrinkView.autoLayout.fill(self.contentView, edges: .init(top: 8, left: 12, bottom: 8, right: 8))
        shrinkView.setupLayout()
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
    }
    
    func setupStyling() {
        
        self.shrinkView.setupStyling()
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

final class ReadItemShrinkCollectionCell: ReadItemShrinkCell {
    
    func setupCell(_ cellViewModel: ReadCollectionCellViewModel) {
        
        self.shrinkView.nameLabel.text = cellViewModel.name
        
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
        let title = title.flatMap{ $0.isNotEmpty ? $0 : nil } ?? "Fail to load preview".localized
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

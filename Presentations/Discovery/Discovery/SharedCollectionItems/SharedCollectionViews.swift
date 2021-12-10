//
//  SharedCollectionViews.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/16.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - SharedCollectionAttrCell

final class SharedCollectionAttrCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = SharedCollectionAttrCellViewModel
    
    private let stackView = UIStackView()
    private let descriptionLabel = UILabel()
    private let categoryView = KeyAndLabeledValueView()
    private let underLineView = UIView()
    
    func setupCell(_ cellViewModel: SharedCollectionAttrCellViewModel) {
        
        let validDesription = cellViewModel.collectionDescription.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.descriptionLabel.isHidden = validDesription == nil
        self.descriptionLabel.text = validDesription
            
        self.updateCategories(cellViewModel.categories)
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
}

extension SharedCollectionAttrCell {
    
    func setupLayout() {
        self.contentView.addSubview(stackView)
        self.stackView.autoLayout.fill(self.contentView, edges: .init(top: 0, left: 14, bottom: 9, right: 14))
        self.stackView.addArrangedSubview(self.descriptionLabel)
        self.stackView.addArrangedSubview(self.categoryView)
        self.descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.descriptionLabel.autoLayout.active {
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 16)
        }
        
        self.categoryView.autoLayout.active(with: self.stackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        self.categoryView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.categoryView.autoLayout.active {
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        }
        self.categoryView.setupLayout()
        
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
        
        self.categoryView.setupStyling()
        self.categoryView.iconView.image = UIImage(systemName: "line.horizontal.3.decrease.circle")
        self.categoryView.keyLabel.text = "Categories".localized
        
        self.descriptionLabel.isHidden = true
        self.categoryView.isHidden = true
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}


// MARK: - SharedCollectionExpandCell

final class SharedCollectionExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = SharedCollectionCellViewModel
    
    private let expandView = ReadItemExppandContentView()
    private let arrowImageView = UIImageView()
    private let underLineView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: SharedCollectionCellViewModel) {
        
        self.expandView.nameLabel.text = cellViewModel.name
        
        let validDescription = cellViewModel.collectionDescription.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.descriptionLabel.isHidden = validDescription == nil
        self.expandView.descriptionLabel.text = validDescription
           
        self.updateCategories(cellViewModel.categories)
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


// MARK: - SharedLinkExpandCell

final class SharedLinkExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = SharedLinkCellViewModel
    
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
    
    func setupCell(_ cellViewModel: SharedLinkCellViewModel) {
        
        self.updateTitle(cellViewModel.customName)
        self.expandView.addressLabel.text = cellViewModel.linkUrl
                
        self.updateCategories(cellViewModel.categories)
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

final class SharedShrinkCollectionCell: ReadItemShrinkCell {
    
    func setupCell(_ cellViewModel: SharedCollectionCellViewModel) {
        
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

final class SharedShrinkLinkCell: ReadItemShrinkCell {
    
    func setupCell(_ cellViewModel: SharedLinkCellViewModel) {
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

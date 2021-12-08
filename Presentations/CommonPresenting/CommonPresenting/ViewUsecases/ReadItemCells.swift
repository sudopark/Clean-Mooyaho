//
//  ReadItemCells.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/27.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics
import ValidationSemigroup

import Domain


// MARK: - DefaultReadCollectionCell

public final class DefaultReadCollectionCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    public typealias CellViewModel = ReadCollectionCellViewModel
    
    public let expandView = ReadItemExppandContentView()
    private let arrowImageView = UIImageView()
    private let underLineView = UIView()
    
    public override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    public func setupCell(_ cellViewModel: ReadCollectionCellViewModel) {
        
        self.expandView.nameLabel.text = cellViewModel.name
        
        self.expandView.updateFavoriteView(cellViewModel.isFavorite)
        
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
    
    public func updateCategories(_ categories: [ItemCategory]) {
        let validCategory = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| self.expandView.categoriesView.updateCategories(_:)
    }
    
    public func setupLayout() {
        
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
    
    public func setupStyling() {
        
        self.arrowImageView.image = UIImage(systemName: "chevron.right")
        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.tintColor = self.uiContext.colors.hintText
        
        self.expandView.setupStyling()
        self.expandView.iconImageView.image = UIImage(systemName: "folder")
        self.expandView.tintColor = self.uiContext.colors.secondaryTitle
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}


// MARK: - DefaultReadLinkCell

public final class DefaultReadLinkCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    public typealias CellViewModel = ReadLinkCellViewModel
    
    private let expandView = ReadItemExppandContentView()
    private let thumbNailView = UIImageView()
    private let underLineView = UIView()
    private var expandViewTrailing: NSLayoutConstraint!
    
    public override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        expandViewTrailing.constant = -12
        self.thumbNailView.cancelSetupThumbnail()
    }
    
    public func setupCell(_ cellViewModel: ReadLinkCellViewModel) {
        
        self.updateTitle(cellViewModel.customName)
        self.updateIsRed(cellViewModel.isRed)
        self.expandView.updateFavoriteView(cellViewModel.isFavorite)
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
        let imageName = isRed ? "checkmark.circle.fill" : "doc.text"
        let imagetintColor = isRed ? UIColor.systemGreen : self.uiContext.colors.secondaryTitle
        self.expandView.iconImageView.image = UIImage(systemName: imageName)
        self.expandView.iconImageView.tintColor = imagetintColor
        
        self.expandView.nameLabel.alpha = isRed ? 0.4 : 1.0
    }
    
    public func updateCategories(_ categories: [ItemCategory]) {
        let validCategory = pure(categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| self.expandView.categoriesView.updateCategories(_:)
    }
    
    public func bindPreview(_ source: Observable<LinkPreview>, customTitle: String?) {
        
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
    
    public func setupLayout() {
        
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
    
    public func setupStyling() {
    
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


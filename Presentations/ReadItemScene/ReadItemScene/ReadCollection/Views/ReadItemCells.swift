//
//  ReadItemCells.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/22.
//

import UIKit

import RxSwift
import RxCocoa

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
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
    }
    
    func setupStyling() {
        self.titleLabel.numberOfLines = 1
        self.titleLabel.font = self.uiContext.fonts.get(22, weight: .black)
        self.titleLabel.textColor = self.uiContext.colors.text
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
        self.titleLabel.numberOfLines = 1
        self.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.titleLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.4)
    }
}


// MARK: - ReadItemCells

public protocol ReadItemCells: BaseTableViewCell {
    
    associatedtype CellViewModel: ReadItemCellViewModel
    
    func setupCell(_ cellViewModel: CellViewModel)
}


// MARK: - section0: ReadCollectionAttrCell

final class KeyAndLabeledValueView: BaseUIView, Presenting {
    let iconView = UIImageView()
    let keyLabel = UILabel()
    let labelView = UILabel()
    
    func setupLayout() {
        
        self.addSubview(iconView)
        iconView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.addSubview(keyLabel)
        keyLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8)
            iconView.centerYAnchor.constraint(equalTo: $0.centerYAnchor)
        }
        keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.addSubview(labelView)
        labelView.autoLayout.active(with: self) {
            $0.firstBaselineAnchor.constraint(equalTo: keyLabel.firstBaselineAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
    }
    
    func setupStyling() {
        self.keyLabel.decorate(self.uiContext.deco.placeHolder)
    }
}

final class ReadCollcetionAttrCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadCollectionAttrCellViewModel
    
    private let stackView = UIStackView()
    private let priorityView = KeyAndLabeledValueView()
    private let categoryView = KeyAndLabeledValueView()
    private let underLineView = UIView()
    
    func setupCell(_ cellViewModel: ReadCollectionAttrCellViewModel) {
        // TODO: setup priority
        // TODO: setup categories
    }
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        self.contentView.addSubview(stackView)
        self.stackView.autoLayout.fill(self.contentView, edges: .init(top: 9, left: 12, bottom: 9, right: 12))
        self.stackView.addArrangedSubview(self.priorityView)
        self.stackView.addArrangedSubview(self.categoryView)
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
    }
    
    func setupStyling() {
        self.stackView.axis = .vertical
        self.stackView.distribution = .fill
        self.stackView.spacing = 6
        
        self.priorityView.isHidden = true
        self.categoryView.isHidden = true
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}


// MARK: - section1: ReadCollectionExpandCell

final class ReadCollectionExpandCell: ReadCollectionShrinkCell {
    
    typealias CellViewModel = ReadCollectionCellViewModel
    
    private let iconImageView = UIImageView()
    private let contentStackView = UIStackView()
    private let nameAreaStackView = UIStackView()
    private let nameLabel = UILabel()
    private let priorityLabel = UILabel()
    private let categoriesTextView = CategoryTextView()
    private let arrowImageView = UIImageView()
    private let underLineView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func setupCell(_ cellViewModel: ReadCollectionCellViewModel) {
        // TODO: setup cell
    }
    
    override func setupLayout() {
        
        super.setupLayout()
        contentStackView.addArrangedSubview(categoriesTextView)
        categoriesTextView.setupLayout()
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
    }
    
    override func setupStyling() {
        
        super.setupStyling()
        
        self.categoriesTextView.setupStyling()
    }
}

// MARK: - section2: ReadLinkExpandCell

final class ReadLinkExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadLinkCellViewModel
    
    let contentStackView = UIStackView()
    
    let thumbNailView = UIImageView()
    
    let titleAreaView = UIView()
    let iconImageVIew = UIImageView()
    let titleLabel = UILabel()
    
    let descriptionView = UILabel()
    
    let linkAreaStackView = UIStackView()
    let linkIconImageView = UIImageView()
    let linkAddressLabel = UILabel()
    let priorityLabel = UILabel()
    let categoriesTextView = CategoryTextView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbNailView.cancelSetupThumbnail()
        self.iconImageVIew.cancelSetupThumbnail()
    }
    
    func setupCell(_ cellViewModel: ReadLinkCellViewModel) {
        
        self.linkAddressLabel.text = cellViewModel.linkUrl
        if cellViewModel.categories.isNotEmpty {
            self.categoriesTextView.isHidden = false
            self.categoriesTextView.updateCategories(cellViewModel.categories)
        } else {
            self.categoriesTextView.isHidden = true
        }
        
        // TODO: update priority
    }
    
    func bindPreview(_ source: Observable<LinkPreview>) {
        
        source.asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                guard let self = self else { return }
                self.updateImageIfPossible(self.thumbNailView, url: preview.mainImageURL)
                self.updateImageIfPossible(self.iconImageVIew, url: preview.iconURL)
                self.updateTitle(preview.title)
                self.updateDescripyion(preview.description)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateImageIfPossible(_ imageView: UIImageView, url: String?) {
        imageView.cancelSetupThumbnail()
        guard let url = url else {
            imageView.isHidden = true
            return
        }
        imageView.isHidden = false
        imageView.setupThumbnail(url)
    }
    
    private func updateTitle(_ title: String?) {
        guard let title = title else {
            self.titleAreaView.isHidden = true
            return
        }
        self.titleAreaView.isHidden = false
        self.titleLabel.text = title
    }
    
    private func updateDescripyion(_ description: String?) {
        guard let description = description else {
            self.descriptionView.isHidden = true
            return
        }
        self.descriptionView.isHidden = false
        self.descriptionView.text = description
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(contentStackView)
        contentStackView.autoLayout.fill(self.contentView)
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        
        contentStackView.addArrangedSubview(thumbNailView)
        thumbNailView.autoLayout.active(with: contentStackView) {
            $0.heightAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.64)
        }
        thumbNailView.isHidden = true
        
        titleAreaView.addSubview(iconImageVIew)
        iconImageVIew.autoLayout.active(with: titleAreaView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        }
        titleAreaView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: titleAreaView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.leadingAnchor.constraint(equalTo: iconImageVIew.trailingAnchor, constant: 4)
            $0.topAnchor.constraint(equalTo: iconImageVIew.topAnchor)
        }
        contentStackView.addArrangedSubview(titleAreaView)
        titleAreaView.isHidden = true
        
        contentStackView.addArrangedSubview(descriptionView)
        descriptionView.isHidden = true
        
        linkAreaStackView.axis = .horizontal
        linkAreaStackView.distribution = .fill
        linkAreaStackView.addArrangedSubview(linkIconImageView)
        linkIconImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 13)
            $0.heightAnchor.constraint(equalToConstant: 13)
        }
        linkAreaStackView.addArrangedSubview(linkAddressLabel)
        
        contentStackView.addArrangedSubview(priorityLabel)
        contentStackView.addArrangedSubview(categoriesTextView)
        categoriesTextView.setupLayout()
        categoriesTextView.isHidden = true
    }
    
    func setupStyling() {
        iconImageVIew.image = UIImage(named: "link")
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = self.uiContext.colors.text
        titleLabel.numberOfLines = 1
        
        descriptionView.decorate(self.uiContext.deco.placeHolder)
        descriptionView.numberOfLines = 2
        
        priorityLabel.font = UIFont.systemFont(ofSize: 12)
        priorityLabel.textColor = .systemBlue
        priorityLabel.numberOfLines = 1
        
        categoriesTextView.setupStyling()
    }
}

// MARK: - ReadCollectionShrinkCell

class ReadCollectionShrinkCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadCollectionCellViewModel
    
    private let iconImageView = UIImageView()
    private let contentStackView = UIStackView()
    private let nameAreaStackView = UIStackView()
    private let nameLabel = UILabel()
    private let priorityLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: ReadCollectionCellViewModel) {
        
    }
    
    func setupLayout() {
        self.contentView.addSubview(iconImageView)
        iconImageView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 4)
        }
        
        self.contentView.addSubview(arrowImageView)
        arrowImageView.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.widthAnchor.constraint(equalToConstant: 12)
            $0.heightAnchor.constraint(equalToConstant: 8)
        }
        
        self.contentView.addSubview(self.contentStackView)
        contentStackView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(equalTo: iconImageView.topAnchor)
            $0.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -4)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 4)
        }
        contentStackView.addArrangedSubview(nameAreaStackView)
        nameAreaStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(priorityLabel)
    }
    
    func setupStyling() {
        self.iconImageView.image = UIImage(named: "folder")
        
        self.contentStackView.axis = .vertical
        self.contentStackView.distribution = .fill
        
        self.nameLabel.font = self.uiContext.fonts.get(14, weight: .regular)
        self.nameLabel.textColor = self.uiContext.colors.text
        self.nameLabel.numberOfLines = 2
        
        self.priorityLabel.font = self.uiContext.fonts.get(13, weight: .medium)
        self.priorityLabel.textColor = .systemBlue
        self.priorityLabel.numberOfLines = 1
        
        self.arrowImageView.image = UIImage(named: "chevron.right")
    }
}

// MARK: - ReadLinkShrinkCell

final class ReadLinkShrinkCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadLinkCellViewModel
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: ReadLinkCellViewModel) {
        
    }
    
    func setupLayout() {
        
    }
    
    func setupStyling() {
        
    }
}


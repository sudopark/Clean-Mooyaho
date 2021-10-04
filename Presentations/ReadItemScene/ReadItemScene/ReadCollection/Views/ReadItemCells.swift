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

public enum ReadItemCellActions {
    case itemSelected(_ itemID: String)
}

public protocol ReadItemCells: BaseTableViewCell {
    
    associatedtype CellViewModel: ReadItemCellViewModel
    
    var cellActionSubject: PublishSubject<ReadItemCellActions>? { get set }
    func setupCell(_ cellViewModel: CellViewModel)
}


// MARK: - section0: ReadCollectionAttrCell

final class ReadCollcetionAttrCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadCollectionAttrCellViewModel
    
    private let stackView = UIStackView()
    private let descriptionLabel = UILabel()
    private let priorityView = KeyAndLabeledValueView()
    private let categoryView = KeyAndLabeledValueView()
    private let underLineView = UIView()
    
    public weak var cellActionSubject: PublishSubject<ReadItemCellActions>?
    
    func setupCell(_ cellViewModel: ReadCollectionAttrCellViewModel) {
        
        let validDesription = cellViewModel.collectionDescription.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.descriptionLabel.isHidden = validDesription == nil
        self.descriptionLabel.text = validDesription
        
        let priotiry = cellViewModel.priority
        self.priorityView.isHidden = priotiry == nil
        priotiry.do <| priorityView.labelView.setupPriority
        
        let validCategories = pure(cellViewModel.categories).flatMap{ $0.isNotEmpty ? $0 : nil }
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
        self.descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.priorityView.autoLayout.active(with: self.stackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        self.priorityView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.categoryView.autoLayout.active(with: self.stackView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        self.categoryView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.priorityView.setupLayout()
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
        
        self.priorityView.setupStyling()
        self.priorityView.iconView.image = UIImage(named: "arrow.up.arrow.down.square")
        self.priorityView.keyLabel.text = "Priority".localized
        
        self.categoryView.setupStyling()
        self.categoryView.iconView.image = UIImage(named: "list.dash")
        self.categoryView.keyLabel.text = "Categories".localized
        
        self.descriptionLabel.isHidden = true
        self.priorityView.isHidden = true
        self.categoryView.isHidden = true
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}


// MARK: - item expand content view

final class ReadItemExppandContentView: BaseUIView, Presenting {
    
    let contentStackView = UIStackView()
    let titleAreaStackView = UIStackView()
    let iconImageView = UIImageView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let descriptionLabel = UILabel()
    let priorityStackView = UIStackView()
    let alarmLabel = UILabel()
    let priorityLabel = ItemLabelView()
    let categoriesView = ItemLabelView()
    
    func setupLayout() {
        
        self.addSubview(contentStackView)
        contentStackView.autoLayout.fill(self)
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        
        contentStackView.addArrangedSubview(titleAreaStackView)
        titleAreaStackView.axis = .horizontal
        titleAreaStackView.spacing = 6
        
        titleAreaStackView.addArrangedSubview(iconImageView)
        iconImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        titleAreaStackView.addArrangedSubview(nameLabel)
        nameLabel.autoLayout.active {
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        contentStackView.addArrangedSubview(addressLabel)
        addressLabel.autoLayout.active(with: contentStackView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 18)
        }
        
        contentStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: contentStackView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
        }
        
        contentStackView.addArrangedSubview(priorityStackView)
        priorityStackView.axis = .horizontal
        priorityStackView.spacing = 4
        
        priorityStackView.addArrangedSubview(priorityLabel)
        priorityLabel.setupLayout()
        priorityLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        priorityStackView.addArrangedSubview(alarmLabel)
        
        contentStackView.addArrangedSubview(categoriesView)
        categoriesView.setupLayout()
    }
    
    func setupStyling() {
        
        _ = nameLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.numberOfLines .~ 1
        
        _ = addressLabel
            |> self.uiContext.decorating.listItemSubDescription(_:)
            |> \.numberOfLines .~ 1
            |> \.isHidden .~ true
        
        _ = descriptionLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.numberOfLines .~ 2
            |> \.isHidden .~ true
        
        self.priorityLabel.setupStyling()
        self.priorityLabel.isHidden = true
        
        _ = alarmLabel
            |> self.uiContext.decorating.listItemAccentText(_:)
            |> \.numberOfLines .~ 1
            |> \.isHidden .~ true
        
        self.categoriesView.setupStyling()
        self.categoriesView.isHidden = true
    }
}

// MARK: - section1: ReadCollectionExpandCell

final class ReadCollectionExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    typealias CellViewModel = ReadCollectionCellViewModel
    
    public weak var cellActionSubject: PublishSubject<ReadItemCellActions>?
    
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
        
        let validCategory = pure(cellViewModel.categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| self.expandView.categoriesView.updateCategories(_:)
            
        self.bindCellSelected(cellViewModel.uid)
    }
    
    private func bindCellSelected(_ itemID: String) {
        
        self.contentView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.cellActionSubject?.onNext(.itemSelected(itemID))
            })
            .disposed(by: self.disposeBag)
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
        
        self.arrowImageView.image = UIImage(named: "chevron.right")
        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.tintColor = self.uiContext.colors.hintText
        
        self.expandView.setupStyling()
        self.expandView.iconImageView.image = UIImage(named: "folder")
        self.expandView.tintColor = self.uiContext.colors.secondaryTitle
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

// MARK: - section2: ReadLinkExpandCell

final class ReadLinkExpandCell: BaseTableViewCell, ReadItemCells, Presenting {
    
    public weak var cellActionSubject: PublishSubject<ReadItemCellActions>?
    
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
        
        self.expandView.addressLabel.text = cellViewModel.linkUrl
        
        let priority = cellViewModel.priority
        self.expandView.priorityLabel.isHidden = priority == nil
        priority.do <| self.expandView.priorityLabel.setupPriority
        
        let validCategory = pure(cellViewModel.categories).flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.categoriesView.isHidden = validCategory == nil
        validCategory.do <| self.expandView.categoriesView.updateCategories(_:)
            
        self.bindCellSelected(cellViewModel.uid)
    }
    
    private func bindCellSelected(_ itemID: String) {
        
        self.contentView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.cellActionSubject?.onNext(.itemSelected(itemID))
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindPreview(_ source: Observable<LinkPreview>) {
        
        source.asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                guard let self = self else { return }
                self.updateThumbnailIfPossible(with: preview.mainImageURL)
                self.updateTitle(preview.title)
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
        self.expandView.iconImageView.image = UIImage(named: "doc.text")
        self.expandView.tintColor = self.uiContext.colors.secondaryTitle
        
        self.expandView.addressLabel.isHidden = false
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        self.expandView.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = false
    }
}

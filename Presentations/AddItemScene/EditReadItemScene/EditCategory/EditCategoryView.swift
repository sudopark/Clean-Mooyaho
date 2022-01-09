//
//  EditCategoryView.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/08.
//

import UIKit

import RxSwift

import Domain
import CommonPresenting


// MARK: - SelectedCategoryCell

final class SelectedCategoryCell: BaseCollectionViewCell {
    
    enum Metrics {
        static func expectCellSize(for name: String, font: UIFont) -> CGSize {
            let expectedWidth = name.expectWidth(font: font)
            let padding: CGFloat = 4
            let width = expectedWidth + padding * 3 + 15
            return CGSize(width: width, height: 24)
        }
    }
    
    let labelView = CategoryLabelView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: SuggestingCategoryCellViewModel) {
        labelView.setupLabel(cellViewModel)
    }
}


extension SelectedCategoryCell: Presenting {
    
    func setupLayout() {
        
        self.contentView.addSubview(labelView)
        labelView.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        labelView.setupLayout()
    }
    
    func setupStyling() {
        
        self.backgroundColor = .clear
        self.labelView.setupStyling()
        self.labelView.updateCloseViewIsHidden(false)
    }
}


// MARK: - SuggestingCategoryCell

final class SuggestingCategoryCell: BaseTableViewCell {
    
    let labelView = CategoryLabelView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
    }
    
    func setupCell(_ cellViewModel: SuggestingCategoryCellViewModel) {
        labelView.setupLabel(cellViewModel)
    }
}

extension SuggestingCategoryCell: Presenting {
    
    func setupLayout() {
        
        self.contentView.addSubview(labelView)
        labelView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
        }
        labelView.setupLayout()
    }
    
    func setupStyling() {
        
        self.labelView.setupStyling()
        self.labelView.updateCloseViewIsHidden(true)
    }
}


// MARK: - SuggestMakeNewCategoryCell
 
final class SuggestMakeNewCategoryCell: BaseTableViewCell {
    
    let createButton = UIButton()
    let labelView = CategoryLabelView()
    let colorView = UIView()
    
    weak var createSubject: PublishSubject<SuggestMakeNewCategoryCellViewMdoel>?
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .disclosureIndicator
    }
    
    func setupCell(_ cellViewModel: SuggestMakeNewCategoryCellViewMdoel) {
        self.labelView.setupLabel(cellViewModel)
        self.colorView.backgroundColor = UIColor.from(hex: cellViewModel.colorCode)
        
        self.createButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.createSubject?.onNext(cellViewModel)
            })
            .disposed(by: self.disposeBag)
    }
}

extension SuggestMakeNewCategoryCell: Presenting {
    
    func setupLayout() {
        
        self.contentView.addSubview(createButton)
        createButton.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.contentView.addSubview(colorView)
        colorView.autoLayout.active(with: self.contentView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.contentView.addSubview(labelView)
        labelView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: createButton.trailingAnchor, constant: 6)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -12)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: colorView.leadingAnchor, constant: -4)
        }
        labelView.setupLayout()
    }
    
    func setupStyling() {
        
        self.createButton.titleLabel?.font = self.uiContext.fonts.get(13.5, weight: .medium)
        self.createButton.setTitle("Create".localized, for: .normal)
        self.createButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        
        self.labelView.setupStyling()
        self.labelView.updateCloseViewIsHidden(true)
        self.labelView.nameLabel.numberOfLines = 2
        
        self.colorView.clipsToBounds = true
        self.colorView.layer.cornerRadius = 7.5
    }
}


extension CategoryLabelView {
    
    func setupLabel(_ cellViewModel: SuggestingCategoryCellViewModelType) {
        self.nameLabel.text = cellViewModel.name
        self.backgroundColor = UIColor.from(hex: cellViewModel.colorCode)
    }
}

//
//  SimpleReadItemCells.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/26.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude

import Domain


// MARK: - SimpleReadItemCell

open class SimpleReadItemCell: BaseTableViewCell, Presenting {
    
    public let shrinkView = ReadItemShrinkContentView()
    public let underLineView = UIView()
    
    open override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    open func setupLayout() {
        self.contentView.addSubview(shrinkView)
        shrinkView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        shrinkView.setupLayout()
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
    }
    
    open func setupStyling() {
        self.shrinkView.setupStyling()
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
    
    public func updateDescription(_ description: String?) {
        let description = description.flatMap { $0.isNotEmpty ? $0 : nil }
        self.shrinkView.descriptionLabel.isHidden = description == nil
        self.shrinkView.descriptionLabel.text = description
    }
}


// MARK: - SimpleReadCollectionCell

open class SimpleReadCollectionCell: SimpleReadItemCell {
    
    open override func setupStyling() {
        super.setupStyling()
        self.shrinkView.iconImageView.image = UIImage(systemName: "folder")
        self.shrinkView.iconImageView.tintColor = self.uiContext.colors.secondaryTitle
    }
}

// MARK: - SimpleReadLinkCell

open class SimpleReadLinkCell: SimpleReadItemCell {
    
    open override func setupStyling() {
        super.setupStyling()
        self.shrinkView.iconImageView.image = UIImage(systemName: "doc.text")
        self.shrinkView.iconImageView.tintColor = self.uiContext.colors.secondaryTitle
    }
    
    public func updateTitle(_ title: String?) {
        let title = title.flatMap{ $0.isNotEmpty ? $0 : nil } ?? "Fail to load preview".localized
        self.shrinkView.nameLabel.text = title
    }
    
    public func bindPreview(_ source: Observable<LinkPreview>, customTitle: String?) {
        
        source
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                guard let self = self else { return }
                (customTitle?.isEmpty ?? true).then <| { self.updateTitle(preview.title) }
                self.updateDescription(preview.description)
            })
            .disposed(by: self.disposeBag)
    }
}

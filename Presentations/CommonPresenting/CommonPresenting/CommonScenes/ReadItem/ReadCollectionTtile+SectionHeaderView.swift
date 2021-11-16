//
//  ReadCollectionTtileHeaderView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/16.
//

import UIKit

import Prelude
import Optics


// MARK: - ReadCollectionTtileHeaderView

public final class ReadCollectionTtileHeaderView: BaseUIView, Presenting {
    
    private let titleLabel = UILabel()
    
    public func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    public func setupLayout() {
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 13)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
    }
    
    public func setupStyling() {
        _ = self.titleLabel |> self.uiContext.decorating.header
    }
}


// MARK: - ReadCollectionSectionHeaderView

public final class ReadCollectionSectionHeaderView: BaseTableViewSectionHeaderFooterView, Presenting {
    
    private let titleLabel = UILabel()
    
    public override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    public func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    public func setupLayout() {
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 4)
        }
    }
    
    public func setupStyling() {
        _ = self.titleLabel |> self.uiContext.decorating.listSectionTitle(_:)
    }
}


extension ReadCollectionItemSectionType {
    
    public func makeSectionHeaderIfPossible() -> ReadCollectionSectionHeaderView? {
        guard self != .attribute else { return nil }
        let header = ReadCollectionSectionHeaderView()
        header.setupTitle(self.rawValue)
        return header
    }
}

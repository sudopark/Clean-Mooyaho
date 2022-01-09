//
//  ReadItemShrinkCell.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/16.
//

import UIKit


open class ReadItemShrinkCell: BaseTableViewCell, Presenting {
    
    public let shrinkView = ReadItemShrinkContentView()
    public let underLineView = UIView()
    
    public override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    open func setupLayout() {
        
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
    
    open func setupStyling() {
        
        self.shrinkView.setupStyling()
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

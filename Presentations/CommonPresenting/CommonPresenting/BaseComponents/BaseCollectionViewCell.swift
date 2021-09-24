//
//  BaseCollectionViewCell.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/22.
//

import UIKit

import RxSwift


open class BaseCollectionViewCell: UICollectionViewCell, UIContextAccessable {
    
    public var disposeBag = DisposeBag()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = .init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.afterViewInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func afterViewInit() {
        self.isSelected = false
    }
}

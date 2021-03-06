//
//  BaseTableViewCell.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import RxSwift


// MARK: - BaseTableViewCell

open class BaseTableViewCell: UITableViewCell, UIContextAccessable {
    
    public var disposeBag: DisposeBag! = DisposeBag()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.afterViewInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open func afterViewInit() {
        self.selectionStyle = .none
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = nil
        self.disposeBag = .init()
    }
}


// BaseTableViewSectionHeaderFooterView

open class BaseTableViewSectionHeaderFooterView: UITableViewHeaderFooterView, UIContextAccessable {
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.afterViewInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open func afterViewInit() {
        
    }
}

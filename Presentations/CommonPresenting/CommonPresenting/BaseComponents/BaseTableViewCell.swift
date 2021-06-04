//
//  BaseTableViewCell.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import RxSwift


open class BaseTableViewCell: UITableViewCell, UIContextAccessable {
    
    public var disposeBag = DisposeBag()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.afterViewInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) { }
    
    open func afterViewInit() {
        
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = .init()
    }
}
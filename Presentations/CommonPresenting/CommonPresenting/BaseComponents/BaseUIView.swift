//
//  BaseUIView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


open class BaseUIView: UIView, UIContextAccessable {
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}

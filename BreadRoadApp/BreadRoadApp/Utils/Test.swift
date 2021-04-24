//
//  Test.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit


extension BaseViewController {
    
    func testPresentViewControllerName() {
        
        let label = UILabel()
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        self.view.backgroundColor = .white
        label.textColor = UIColor.black
        
        let name = String(describing: type(of: self))
        label.text = name
    }
}

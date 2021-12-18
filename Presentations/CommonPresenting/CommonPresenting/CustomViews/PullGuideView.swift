//
//  TopPullView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/12/19.
//

import UIKit


public final class PullGuideView: BaseUIView, Presenting {
 
    let lineView = UIView()
    
    public func setupLayout() {
        
        self.addSubview(lineView)
        lineView.autoLayout.active(with: self) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.heightAnchor.constraint(equalToConstant: 6)
            $0.widthAnchor.constraint(equalToConstant: 50)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 9)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -9)
        }
    }
    
    public func setupStyling() {
     
        self.lineView.layer.cornerRadius = 3
        self.lineView.clipsToBounds = true
        self.lineView.backgroundColor = UIColor.lightGray
    }
}


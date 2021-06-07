//
//  BaseBottomSlideMenuView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/07.
//

import UIKit


open class BaseBottomSlideMenuView: BaseUIView {
    
    public let outsideTouchView = UIView()
    public let containerView = UIView()
    
    public var containerButtonConstraint: NSLayoutConstraint!

}


extension BaseBottomSlideMenuView: Presenting {
    
    public func setupLayout() {
        self.addSubview(outsideTouchView)
        outsideTouchView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor, multiplier: 3/7)
        }
        
        self.addSubview(containerView)
        containerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
        }
        self.containerButtonConstraint = containerView.bottomAnchor
            .constraint(equalTo: self.bottomAnchor, constant: 10)
        NSLayoutConstraint.activate([self.containerButtonConstraint])
    }
    
    public func setupStyling() {
        
        self.outsideTouchView.backgroundColor = .clear
        
        self.containerView.backgroundColor = self.uiContext.colors.appBackground
        self.containerView.layer.cornerRadius = 10
        self.containerView.clipsToBounds = true
    }
}

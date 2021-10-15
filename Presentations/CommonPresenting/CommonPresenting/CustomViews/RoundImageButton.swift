//
//  RoundImageButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/16.
//

import UIKit
import RxSwift
import RxCocoa


public final class RoundImageButton: BaseUIView {
    
    public var edge: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4) {
        didSet {
            self.paddingLeft?.constant = edge.left
            self.paddingTop?.constant = edge.top
            self.paddingRight?.constant = -edge.right
            self.paddingBottom?.constant = -edge.bottom
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            self.imageView.tintColor = tintColor
        }
    }
    
    public var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    
    let imageView = UIImageView()
    let button = UIButton()
    
    private var paddingTop: NSLayoutConstraint!
    private var paddingLeft: NSLayoutConstraint!
    private var paddingRight: NSLayoutConstraint!
    private var paddingBottom: NSLayoutConstraint!
}

extension RoundImageButton {
    
    public func updateRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}


extension Reactive where Base == RoundImageButton {
    
    public func throttleTap() -> Observable<Void> {
        return base.button.rx.throttleTap()
    }
}

extension RoundImageButton: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.paddingTop = imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.edge.top)
        self.paddingTop.isActive = true
        
        self.paddingLeft = imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.edge.left)
        self.paddingLeft.isActive = true
        
        self.paddingRight = imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.edge.right)
        self.paddingRight.isActive = true
        
        self.paddingBottom = imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.edge.bottom)
        self.paddingBottom.isActive = true
        
        self.addSubview(button)
        button.autoLayout.fill(self)
    }
    
    public func setupStyling() { }
}

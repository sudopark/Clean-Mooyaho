//
//  RoundShadowView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/16.
//

import UIKit


public class RoundShadowView: BaseUIView {
    
    private var shadowLayer: CAShapeLayer!
    public var cornerRadius: CGFloat = 15.0
    public var fillColor: UIColor = .white
    
    public func updateLayer() {
        self.shadowLayer = nil
        self.layoutIfNeeded()
    }
    
    public override func layoutSubviews() {
        guard self.shadowLayer == nil else { return }
        
        let newLayer = CAShapeLayer()
        newLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).cgPath
        newLayer.fillColor = self.fillColor.cgColor
        newLayer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        newLayer.shadowPath = newLayer.path
        newLayer.shadowOffset = .init(width: 0, height: 0.1)
        newLayer.shadowOpacity = 0.4
        newLayer.shadowRadius = self.cornerRadius
        
        self.shadowLayer = newLayer
        
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
}

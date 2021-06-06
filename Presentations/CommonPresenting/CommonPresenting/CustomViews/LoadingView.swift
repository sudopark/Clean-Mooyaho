//
//  LoadingView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit


public final class LoadingView: BaseUIView {
    
    enum Constants {
        static let rotationAnimKey = "loadingview.rotation"
        static let strokeAnimKey = "loadingView.stroke"
    }
    
    private var loadingLayer: CAShapeLayer!
    private var completeLayer: CAShapeLayer!
    
    public var layerColor = UIColor.white
    
    public func updateIsLoading(_ isLoading: Bool) {
        if isLoading {
            self.showIsLoading()
        } else {
            self.removeAllAnimation()
            self.isHidden = true
        }
    }
    
    deinit {
        self.removeAllAnimation()
    }
}

extension LoadingView: CAAnimationDelegate {
    
    private func removeAllAnimation() {
        
    }
    
    private func setupLoadinLayer() {
        
        let layer = CAShapeLayer()
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        layer.bounds = self.bounds
        layer.position = center
        
        let radius = self.bounds.height * 0.8
        layer.path = UIBezierPath(arcCenter: center, radius: radius,
                                  startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = self.layerColor.cgColor
        layer.lineWidth = 3.5
        layer.lineCap = .round
        layer.isHidden = true
        self.loadingLayer = layer
        self.layer.addSublayer(self.loadingLayer)
    }
    
    private func showIsLoading() {
        self.removeAllAnimation()
        self.setupLoadinLayer()
        
        self.isHidden = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.delegate = self
        self.loadingLayer?.add(rotationAnimation, forKey: Constants.rotationAnimKey)
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.2
        strokeAnimation.toValue = 0.8
        strokeAnimation.duration = 1.2
        strokeAnimation.repeatCount = .infinity
        strokeAnimation.delegate = self
        strokeAnimation.autoreverses = true
        self.loadingLayer.add(strokeAnimation, forKey: Constants.strokeAnimKey)
    }
    
    public func animationDidStart(_ anim: CAAnimation) {
        guard anim == self.loadingLayer.animation(forKey: Constants.strokeAnimKey) else { return }
        self.loadingLayer.isHidden = false
    }
}

extension LoadingView: Presenting {
    
    public func setupLayout() {}
    
    public func setupStyling() {
        self.isHidden = true
    }
}

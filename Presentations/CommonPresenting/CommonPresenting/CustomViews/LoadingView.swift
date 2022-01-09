//
//  LoadingView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit


// MARK: - LoadingView

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
        
        let radius = self.bounds.height * 0.35
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


// MARK: - FullScreenLoadingView

public final class FullScreenLoadingView: BaseUIView {
    
    private let containerView = UIView()
    private let loadingView = LoadingView()
    private let messageLabel = UILabel()
    
    public func updateIsLoading(_ isLoading: Bool) {
        if isLoading {
            self.isHidden = false
            self.loadingView.updateIsLoading(true)
        } else {
            self.loadingView.updateIsLoading(false)
            self.isHidden = true
        }
    }
}

extension FullScreenLoadingView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(containerView)
        containerView.autoLayout.active(with: self) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor, constant: 40)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -40)
            $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
        }
        
        self.containerView.addSubview(loadingView)
        loadingView.autoLayout.active(with: containerView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 32)
            $0.widthAnchor.constraint(equalToConstant: 50)
            $0.heightAnchor.constraint(equalToConstant: 50)
        }
        
        self.containerView.addSubview(messageLabel)
        messageLabel.autoLayout.active(with: self.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 12)
        }
    }
    
    public func setupStyling() {
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.containerView.layer.cornerRadius = 16
        self.containerView.clipsToBounds = true
        
        self.uiContext.decorating.listItemTitle(self.messageLabel)
        self.messageLabel.textColor = .white.withAlphaComponent(0.8)
        self.messageLabel.text = "Wait please..".localized
        
        self.isHidden = true
        self.isUserInteractionEnabled = true
    }
}

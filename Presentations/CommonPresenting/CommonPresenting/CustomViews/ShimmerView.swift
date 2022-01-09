//
//  ShimmerView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/03.
//

import UIKit

import Prelude
import Optics


public class BaseShimmerView: BaseUIView {

    public var shimmerColor: UIColor!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.shimmerColor = UIColor(white: 0.80, alpha: 0.6)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var shimmerLayer: CAGradientLayer?
    
    public func startAnimation() {
        
        self.stopAnimation()
        
        let shimmerLayer = self.shimmerLayer ?? self.makeGradientLayer()
        let animation = self.makeAnimation()
        
        self.layer.addSublayer(shimmerLayer)
        shimmerLayer.add(animation, forKey: animation.keyPath)
        self.shimmerLayer = shimmerLayer
    }
    
    public func stopAnimation() {
        self.shimmerLayer?.removeAllAnimations()
        self.shimmerLayer?.removeFromSuperlayer()
        self.layer.removeAllAnimations()
        self.shimmerLayer = nil
    }
}


extension BaseShimmerView {
    
    private func makeGradientLayer() -> CAGradientLayer {
        
        let gradientColorOne : CGColor = UIColor(white: 0.85, alpha: 0.6).cgColor
        let gradientColorTwo : CGColor = UIColor(white: 0.95, alpha: 0.6).cgColor
        
        let gradientLayer = CAGradientLayer()
                
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        return gradientLayer
    }
    
    private func makeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }
}



public class SingleLineShimmerView: BaseShimmerView, Presenting {
    
    public func setupLayout() { }
    
    public func setupStyling() {
        self.backgroundColor = self.shimmerColor
        
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
    }
}

public class MultilineShimmerView: BaseShimmerView, Presenting {
    
    public var lineHeight: CGFloat = 15
    public var lineSpaing: CGFloat = 6
    public var numberOfLines: Int = 2
    
    private var lineViews: [SingleLineShimmerView] = []
    
    public override func startAnimation() {
        self.lineViews.forEach { $0.startAnimation() }
    }
    
    public override func stopAnimation() {
        self.lineViews.forEach { $0.stopAnimation() }
    }
    
    public func setupLayout() {
        
        self.lineViews = (0..<self.numberOfLines).map { _ in
            return SingleLineShimmerView()
                |> \.shimmerColor .~ self.shimmerColor
        }
        self.lineViews.enumerated().forEach { offset, line in
            let topView = self.lineViews[safe: offset-1]
            let lastLineRatio: CGFloat = offset == self.lineViews.count-1 && offset != 0 ? 0.6 : 1.0
            self.addLineView(newLine: line, under: topView, widthRatio: lastLineRatio)
        }
    }
    
    private func addLineView(newLine: SingleLineShimmerView,
                             under topView: UIView?,
                             widthRatio: CGFloat = 1.0) {
        
        let topAnchor = topView?.bottomAnchor ?? self.topAnchor
        
        self.addSubview(newLine)
        newLine.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: widthRatio)
            $0.heightAnchor.constraint(equalToConstant: self.lineHeight)
            $0.topAnchor.constraint(equalTo: topAnchor, constant: self.lineSpaing)
        }
        newLine.setupLayout()
    }
    
    public func setupStyling() {
        
        self.lineViews.forEach {
            $0.setupStyling()
        }
    }
}



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
    public var shadowOpacity: Float = 0.4
    public var shadowColor: UIColor = UIColor.label
    
    public func updateLayer() {
        self.shadowLayer?.removeAllAnimations()
        self.shadowLayer?.removeFromSuperlayer()
        self.shadowLayer = nil
        self.layoutIfNeeded()
    }
    
    public override func layoutSubviews() {
        guard self.shadowLayer == nil else { return }
        
        let newLayer = CAShapeLayer()
        newLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).cgPath
        newLayer.fillColor = self.fillColor.cgColor
        let alpha: CGFloat = self.traitCollection.userInterfaceStyle == .light ? 0.4 : 0.1
        newLayer.shadowColor = shadowColor.withAlphaComponent(alpha).cgColor
        newLayer.shadowPath = newLayer.path
        newLayer.shadowOffset = .init(width: 0, height: 0.1)
        newLayer.shadowOpacity = self.shadowOpacity
        newLayer.shadowRadius = self.cornerRadius
        
        self.shadowLayer = newLayer
        
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let previous = previousTraitCollection?.userInterfaceStyle,
              previous != self.traitCollection.userInterfaceStyle else { return }
        self.updateLayer()
    }
}



import SwiftUI

extension Views {
    
    public struct RoundShadowView: View {
        
        @Environment(\.colorScheme) private var colorScheme: ColorScheme
        private let customBackgroundColor: Color?
        private let cornerRadidus: CGFloat
        public init(
            customBackgroundColor: Color? = nil,
            cornerRadidus: CGFloat
        ) {
            self.customBackgroundColor = customBackgroundColor
            self.cornerRadidus = cornerRadidus
        }
        
        public var body: some View {
            let shadowAlpha: CGFloat = colorScheme == .light ? 0.4 : 0.1
            let shadowColor = UIColor.label.withAlphaComponent(shadowAlpha).asColor
            let backgroundColor = self.customBackgroundColor ?? theme.colors.appBackground.asColor
            return RoundedRectangle(cornerRadius: self.cornerRadidus)
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 0.1, y: 0.1)
        }
    }

}

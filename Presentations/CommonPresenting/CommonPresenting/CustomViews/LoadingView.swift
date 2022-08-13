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
    
    public var layerColor = UIColor.white
    
    public func updateIsLoading(_ isLoading: Bool) {
        if isLoading {
            self.showIsLoading()
        } else {
            self.isHidden = true
        }
    }
}

extension LoadingView: CAAnimationDelegate {
    
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


import SwiftUI

// MARK: SwiftUI Version - LoadingView

extension Views {
    
    
    public struct LoadingView: View {
        
        @Binding var isLoading: Bool
        @State private var percent: CGFloat = 0
        private let layerColor: Color
        
        public init(_ layerColor: Color, isLoading: Binding<Bool>) {
            self.layerColor = layerColor
            self._isLoading = isLoading
        }
        
        public var body: some View {
            
            Views.ProgessLine()
                .trim(from: 0, to: self.percent)
                .stroke(
                    self.layerColor,
                    style: .init(lineWidth: 3.5, lineCap: .round)
                )
                .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true))
                .aspectRatio(1, contentMode: .fit)
                .rotationEffect(Angle(degrees: 360 * self.percent))
                .animation(.linear(duration: 0.9).repeatForever(autoreverses: false))
                .onAppear {
                    self.percent = 1.0
                }
        }
    }
    
    struct ProgessLine: Shape {

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
            let radius = rect.size.height * 0.35
            path.addArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: 360 * 0.1),
                endAngle: Angle(degrees: 360 * 1.2),
                clockwise: true
            )
            return path
        }
    }
}


// MARK: SwiftUI Version - FullScreenLoadingView

extension Views {
    
    public struct FullScreenLoadingView: View {
        
        @Binding var isLoading: Bool
        
        public init(isLoading: Binding<Bool>) {
            self._isLoading = isLoading
        }
        
        public var body: some View {
            if isLoading {
                VStack {
                    self.messageLabel
                    self.loadingView
                }
                .padding(20)
                .background(Color.black.opacity(0.8))
                .cornerRadius(16)
            } else {
                EmptyView()
            }
        }
        
        private var messageLabel: some View {
            Text("Wait please..".localized)
                .foregroundColor(.white.opacity(0.8))
                .font(self.theme.fonts.get(15, weight: .medium).asFont)
        }
        
        private var loadingView: some View {
            Views.LoadingView(.white, isLoading: $isLoading)
                .frame(width: 50, height: 50)
        }
    }
}


struct FullScreenLoadingViewPreview: PreviewProvider {
    
    static var previews: some View {
        
        let loadingView = Views.FullScreenLoadingView(isLoading: .constant(true))
        return loadingView
    }
}

//
//  VisualEffectView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/11/13.
//

import UIKit
import SwiftUI


public struct VisualEffectView: UIViewRepresentable {
    
    private let style: UIBlurEffect.Style
    public init(style: UIBlurEffect.Style = .prominent) {
        self.style = style
    }
    
    public func makeUIView(context: Context) -> some UIView {
        return UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) { }
}

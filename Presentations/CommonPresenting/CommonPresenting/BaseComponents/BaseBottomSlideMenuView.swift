//
//  BaseBottomSlideMenuView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/07.
//

import UIKit


// MARK: - BaseBottomSlideMenuView

open class BaseBottomSlideMenuView: BaseUIView {
    
    public let outsideTouchView = UIView()
    private let sheetContnetView = UIView()
    private let pullGuideView = PullGuideView()
    public let containerView = UIView()
    public let bottomAreaView = UIView()
    
    public var containerBottomConstraint: NSLayoutConstraint!

    public var panGestureInteractView: UIView {
        return self.sheetContnetView
    }
}

extension BaseBottomSlideMenuView: InputKeyboardHandlable {
    
    public var bottomOffset: CGFloat { 10 }
    public var movingContentBottomConsttaint: NSLayoutConstraint? { self.containerBottomConstraint }
}

extension BaseBottomSlideMenuView: Presenting {
    
    public func setupLayout() {
        self.addSubview(outsideTouchView)
        outsideTouchView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.addSubview(sheetContnetView)
        sheetContnetView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        sheetContnetView.addSubview(pullGuideView)
        pullGuideView.autoLayout.active(with: sheetContnetView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
        }
        pullGuideView.setupLayout()
        
        sheetContnetView.addSubview(containerView)
        containerView.autoLayout.active(with: sheetContnetView) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: pullGuideView.bottomAnchor)
        }
        self.containerBottomConstraint = containerView.bottomAnchor
            .constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: bottomOffset)
        NSLayoutConstraint.activate([self.containerBottomConstraint])
        
        self.addSubview(bottomAreaView)
        bottomAreaView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
    }
    
    public func setupStyling() {
        
        self.outsideTouchView.backgroundColor = .clear
        
        self.pullGuideView.setupStyling()
        
        self.sheetContnetView.backgroundColor = self.uiContext.colors.appBackground
        self.sheetContnetView.layer.cornerRadius = 10
        self.sheetContnetView.clipsToBounds = true
        
        self.bottomAreaView.backgroundColor = self.uiContext.colors.appBackground
    }
}


// MARK: - SwiftUI BaseBottomSlideMenuView

import SwiftUI

extension Views {
    
    public struct BaseBottomSlideMenuView<Content: View>: View {
        
        private let content: () -> Content
        public init(_ content: @escaping () -> Content) {
            self.content = content
        }
        
        public var body: some View {
            
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    
                    Views.PullGuideView()
                    
                    self.content()
                        .padding(.top, 4)
                }
                .padding(.bottom, 20)
                .background(self.uiContext.colors.appBackground.asColor)
                .cornerRadius(10, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

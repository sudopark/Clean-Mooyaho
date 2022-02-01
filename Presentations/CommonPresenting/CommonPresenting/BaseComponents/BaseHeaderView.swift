//
//  BaseHeaderView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/01.
//

import UIKit


open class BaseHeaderView: BaseUIView {
    
    
    public var closeButton: UIButton?
    private let contentStackView = UIStackView()
    private var mainContentAsSpaceView: UIView? = UIView()
    
    public func setupMainContentView(_ mainSubView: UIView, onlyWhenCloseNotNeed: Bool = false) {
        let isNoNeedToSetup = onlyWhenCloseNotNeed == true && self.closeButton != nil
        guard isNoNeedToSetup == false else { return }
        
        self.removeSpaceView()
        
        self.contentStackView.addArrangedSubview(mainSubView)
        mainSubView.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
    }
}


extension BaseHeaderView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(contentStackView)
        contentStackView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 20
        
        self.setupCloseButtonIfNeed()
        
        let spaceView = UIView()
        contentStackView.addArrangedSubview(spaceView)
        spaceView.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
        self.mainContentAsSpaceView = spaceView
    }
    
    private func removeSpaceView() {
        guard let spaceView = self.mainContentAsSpaceView else { return }
        self.contentStackView.removeArrangedSubview(spaceView)
        self.mainContentAsSpaceView = nil
    }
    
    private func setupCloseButtonIfNeed() {
        guard ProcessInfo.processInfo.isiOSAppOnMac else { return }
        let button = UIButton()
        self.contentStackView.addArrangedSubview(button)
        self.closeButton = button
    }
    
    public func setupStyling() {
        
        self.closeButton?.setTitle("Close".localized, for: .normal)
        self.closeButton?.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
    }
}

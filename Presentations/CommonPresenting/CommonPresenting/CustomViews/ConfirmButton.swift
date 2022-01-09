//
//  ConfirmButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit


public final class ConfirmButton: BaseUIView {
    
    let button = UIButton(type: .system)
    public let loadingView = LoadingView()
    
    public var title: String? {
        didSet {
            self.button.setTitle(title, for: .normal)
        }
    }

    public var isEnabled: Bool = true {
        didSet {
            self.isUserInteractionEnabled = isEnabled
            self.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    public func updateIsLoading(_ isLoading: Bool) {
        if isLoading {
            self.button.isHidden = true
            self.loadingView.updateIsLoading(true)
        } else {
            self.loadingView.updateIsLoading(false)
            self.button.isHidden = false
        }
    }
}


extension ConfirmButton: Presenting {
    
    public func setupLayout(_ parentView: UIView) {
        
        parentView.addSubview(self)
        self.autoLayout.active(with: parentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        self.setupLayout()
    }
    
    public func setupLayout() {
        
        self.addSubview(button)
        button.autoLayout.fill(self)
        
        self.addSubview(loadingView)
        loadingView.autoLayout.fill(self)
        loadingView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = self.uiContext.colors.accentColor
        
        self.loadingView.setupStyling()
        self.button.setTitleColor(self.loadingView.layerColor, for: .normal)
        self.button.setTitle("Confirm".localized, for: .normal)
        self.button.titleLabel?.font = self.uiContext.fonts.get(16, weight: .medium)
    }
}


import RxSwift
import RxCocoa

extension Reactive where Base: ConfirmButton {
    
    public func throttleTap() -> Observable<Void> {
        return base.button.rx.throttleTap()
    }
    
    public var isLoading: Binder<Bool> {
        Binder(base) { base, isLoading in
            base.updateIsLoading(isLoading)
        }
    }
}

//
//  LoadingButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit


public final class LoadingButton: BaseUIView {
    
    let button = UIButton()
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


extension LoadingButton: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(button)
        button.autoLayout.activeFill(self)
        
        self.addSubview(loadingView)
        loadingView.autoLayout.activeFill(self)
        loadingView.setupLayout()
    }
    
    public func setupStyling() { }
}


import RxSwift
import RxCocoa

extension Reactive where Base: LoadingButton {
    
    public var tap: ControlEvent<Void> {
        return base.button.rx.tap
    }
}

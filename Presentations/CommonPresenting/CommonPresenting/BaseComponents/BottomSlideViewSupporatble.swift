//
//  BottomSlideViewSupporatble.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import UIKit


// MARK: - BottomSlideViewSupporatble

public protocol BottomSlideViewSupporatble {
    
    var bottomSlideMenuView: BaseBottomSlideMenuView { get }
    
    func requestCloseScene()
}

extension BottomSlideViewSupporatble where Self: BaseViewController {
    
    public func setupBottomSlideLayout() {
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
    }
    
    public func bindBottomSlideMenuView() {
        
        self.bottomSlideMenuView
            .bindKeyboardFrameChangesIfPossible()?.disposed(by: self.disposeBag)
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.requestCloseScene()
            })
            .disposed(by: self.disposeBag)
        
        self.bottomSlideMenuView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
    }
}

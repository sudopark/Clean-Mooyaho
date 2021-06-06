//
//  HoorayActionToolbar.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit

import CommonPresenting

class HoorayActionToolbar: UIToolbar {
    
    weak var skipButton: UIBarButtonItem?
    weak var nextButton: UIBarButtonItem?
    
    var showSkip: Bool = true
}


extension HoorayActionToolbar: Presenting {
    
    func setupLayout() {
        
        let skipButton: UIBarButtonItem? = self.showSkip
            ? .init(title: "Skip", style: .plain, target: nil, action: nil)
            : nil
        let nextButton: UIBarButtonItem = .init(title: "Next", style: .done, target: nil, action: nil)
        let buttons: [UIBarButtonItem?] = [skipButton, nextButton]
        
        self.setItems(buttons.compactMap{ $0 }, animated: false)
        self.skipButton = skipButton
        self.nextButton = nextButton
    }
    
    func setupStyling() {
        
        self.barStyle = .default
        self.isUserInteractionEnabled = true
    }
}

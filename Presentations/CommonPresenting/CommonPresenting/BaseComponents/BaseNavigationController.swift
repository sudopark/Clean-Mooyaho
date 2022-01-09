//
//  BaseNavigationController.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/20.
//

import UIKit

import RxSwift


open class BaseNavigationController: UINavigationController, UIContextAccessable {
    
    public var shouldHideNavigation: Bool = true
    public let dispsoseBag: DisposeBag = DisposeBag()
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.shouldHideNavigation else { return }
        self.setNavigationBarHidden(true, animated: false)
    }
}

//
//  BaseNavigationController.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/20.
//

import UIKit

import RxSwift


open class BaseNavigationController: UINavigationController, UIContextAccessable {
    
    public let dispsoseBag: DisposeBag = DisposeBag()
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarHidden(true, animated: false)
    }
}

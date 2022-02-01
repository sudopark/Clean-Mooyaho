//
//  BaseNavigationController.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/20.
//

import UIKit

import RxSwift


open class BaseNavigationController: UINavigationController, UIContextAccessable {
    
    private let shouldHideNavigation: Bool
    private let shouldShowCloseButtonIfNeed: Bool
    public let dispsoseBag: DisposeBag = DisposeBag()
    
    public init(rootViewController: UIViewController? = nil,
                shouldHideNavigation: Bool = true,
                shouldShowCloseButtonIfNeed: Bool = false) {
        
        self.shouldHideNavigation = shouldHideNavigation
        self.shouldShowCloseButtonIfNeed = shouldShowCloseButtonIfNeed
        if let root = rootViewController {
            super.init(rootViewController: root)
        } else {
            super.init(nibName: nil, bundle: nil)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        
        self.rx.viewWillAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.setupCloseButtonIfNeed()
            })
            .disposed(by: self.dispsoseBag)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.shouldHideNavigation else { return }
        self.setNavigationBarHidden(true, animated: false)
    }
}


extension BaseNavigationController {
    
    private func setupCloseButtonIfNeed() {
        guard self.shouldShowCloseButtonIfNeed,
              let firstViewController = self.viewControllers.first else { return }
        let closeButton = UIBarButtonItem(systemItem: .close, primaryAction: nil, menu: nil)
        firstViewController.navigationItem.leftBarButtonItem = closeButton
        
        firstViewController.navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.dispsoseBag)
    }
}

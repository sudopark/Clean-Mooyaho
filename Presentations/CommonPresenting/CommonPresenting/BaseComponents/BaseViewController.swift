//
//  BaseViewController.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Domain


public protocol BaseViewControllable: UIViewController { }

extension BaseViewControllable {
    
    public func presentPageSheetOrFullScreen(_ viewControllerToPresent: UIViewController,
                                             animated flag: Bool,
                                             completion: (() -> Void)? = nil) {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        } else {
            viewControllerToPresent.modalPresentationStyle = .pageSheet
        }
        self.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

open class BaseViewController: UIViewController, BaseViewControllable, UIContextAccessable {
    
    public let disposeBag: DisposeBag = DisposeBag()
    
    public var isKeyCommandCloseEnabled = false
    
    open override var keyCommands: [UIKeyCommand]? {
        guard self.isKeyCommandCloseEnabled == true else { return nil }
        return [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(self.handleEscKeyPressend))
        ]
    }
   
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.print(level: .debug, "will Appear -> \(String(describing: Self.self))")
    }
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        (viewControllerToPresent as? BaseViewController)?.isKeyCommandCloseEnabled = true
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}


extension BaseViewController {
    
    public func setupFullScreenLoadingViewLayout(_ loadingView: FullScreenLoadingView) {
        self.view.addSubview(loadingView)
        loadingView.autoLayout.fill(self.view)
        loadingView.setupLayout()
    }
}


// MARK: - handle keycommand

extension BaseViewController {
    
    @objc open func handleEscKeyPressend() {
        guard self.viewIfLoaded?.window != nil else { return }
        logger.print(level: .debug, "esc key pressed from => \(self) will dismiss")
        self.dismiss(animated: true, completion: nil)
    }
}

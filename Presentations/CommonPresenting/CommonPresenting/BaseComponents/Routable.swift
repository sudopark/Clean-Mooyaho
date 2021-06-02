//
//  Routable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift

import Domain

// MARK: Routing and Router

public protocol Routing: AnyObject {
    
    func alertError(_ error: Error)
    
    func showToast(_ message: String)
    
    func closeScene(animated: Bool, completed: (() -> Void)?)
    
    func alertForConfirm(_ form: AlertForm)
}
extension Routing {
    
    public func alertError(_ error: Error) { }
    
    public func showToast(_ message: String) { }
    
    public func closeScene(animated: Bool, completed: (() -> Void)?) { }
    
    public func alertForConfirm(_ form: AlertForm) { }
}


open class Router<Buildables>: Routing {
    
    public final let nextScenesBuilder: Buildables?
    public weak var currentScene: Scenable?
    
    public init(nextSceneBuilders: Buildables) {
        self.nextScenesBuilder = nextSceneBuilders
    }
}



extension Router {
    
    public func alertError(_ error: Error) {
        logger.todoImplement()
    }
    
    public func showToast(_ message: String) {
        logger.todoImplement()
    }
    
    public func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.currentScene?.dismiss(animated: true, completion: completed)
    }
    
    public func alertForConfirm(_ form: AlertForm) {
        
        
        let alert = UIAlertController(title: form.title, message: form.message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: form.customConfirmText ?? "Confirm".localized,
                                          style: .default) { _ in
            form.confirmed?()
        }
        
        let cancelAction = UIAlertAction(title: form.customCloseText ?? "Cancel".localized,
                                         style: .cancel) { _ in
            form.canceled?()
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.currentScene?.present(alert, animated: true, completion: nil)
    }
}


// MARK: - AlertBuilder

public final class AlertForm {
    
    public var title: String?
    public var message: String?
    public var customConfirmText: String?
    public var customCloseText: String?
    public var confirmed: (() -> Void)?
    public var canceled: (() -> Void)?
    public var isSingleConfirmButton: Bool = false
    
    public init() {}
}

public typealias AlertBuilder = Builder<AlertForm>

extension AlertBuilder {
    
    public func build() -> Base? {
        
        let asserting: (Base) -> Bool = { form in
            if form.title == nil && form.message == nil {
                return false
            }
            return true
        }
        
        return build(with: asserting)
    }
}

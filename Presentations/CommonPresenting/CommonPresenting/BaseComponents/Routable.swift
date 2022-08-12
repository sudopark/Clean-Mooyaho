//
//  Routable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import Prelude
import Optics
import Toaster

import Domain
import Extensions


// MARK: Routing and Router

@MainActor
public protocol Routing: AnyObject {
    
    func alertError(_ error: Error)
    
    func showToast(_ message: String)
    
    func closeScene(animated: Bool, completed: (() -> Void)?)
    
    func alertForConfirm(_ form: AlertForm)
    
    func alertActionSheet(_ form: ActionSheetForm)
    
    func rewind(animated: Bool)
    
    func openURL(_ path: String)
}
extension Routing {
 
    public func alertError(_ error: Error) { }
    
    public func showToast(_ message: String) { }
    
    public func closeScene(animated: Bool, completed: (() -> Void)?) { }
    
    public func alertForConfirm(_ form: AlertForm) { }
    
    public func alertActionSheet(_ form: ActionSheetForm) { }
    
    public func rewind(animated: Bool) { }
    
    public func openURL(_ path: String) { }
}


open class Router<Buildables>: Routing {
    
    public final let nextScenesBuilder: Buildables?
    public weak var currentScene: Scenable?
    
    public init(nextSceneBuilders: Buildables) {
        self.nextScenesBuilder = nextSceneBuilders
    }
    
    public var currentBaseViewControllerScene: BaseViewControllable? {
        return self.currentScene as? BaseViewControllable
    }
}



extension Router {
    
    public func alertError(_ error: Error) {
        let errorDescrition = (error as NSError).description
        let form = AlertForm()
            |> \.title .~ pure("The operation failed.".localized)
            |> \.message .~ pure("The requested operation has failed. Please try again later. (error: %@)".localized(with: errorDescrition))
            |> \.isSingleConfirmButton .~ true
        self.alertForConfirm(form)
        logger.print(level: .debug, "alert error: \(error)")
    }
    
    public func showToast(_ message: String) {
        ToastCenter.default.cancelAll()
        let toast = Toast(text: message)
        toast.show()
    }
    
    public func closeScene(animated: Bool, completed: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            let target = self?.currentScene?.presentingViewController ?? self?.currentScene
            target?.dismiss(animated: true, completion: completed)
        }
    }
    
    public func rewind(animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.currentScene?.navigationController?.popViewController(animated: animated)
        }
    }
    
    public func alertForConfirm(_ form: AlertForm) {
        
        
        let alert = UIAlertController(title: form.title, message: form.message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: form.customConfirmText ?? "Confirm".localized,
                                          style: .default) { _ in
            form.confirmed?()
        }
        alert.addAction(confirmAction)
        
        if form.isSingleConfirmButton == false {
            let cancelAction = UIAlertAction(title: form.customCloseText ?? "Cancel".localized,
                                             style: .cancel) { _ in
                form.canceled?()
            }
            alert.addAction(cancelAction)
        }
        self.currentScene?.present(alert, animated: true, completion: nil)
    }
    
    public func alertActionSheet(_ form: ActionSheetForm) {
        assert(form.actions.isNotEmpty)
        
        let sheet = UIAlertController(title: form.title, message: form.message, preferredStyle: .actionSheet)
        form.actions.forEach { actionFrom in
            let action = UIAlertAction(title: actionFrom.text,
                                       style: actionFrom.isCancel ? .cancel : .default) { _ in
                actionFrom.selected?()
            }
            sheet.addAction(action)
        }
        
        self.currentScene?.present(sheet, animated: true, completion: nil)
    }
    
    public func openURL(_ path: String) {
        guard let url = URL(string: path),
              UIApplication.shared.canOpenURL(url)
        else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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


// MARK: - ActionSheetForm

public class ActionSheetForm {
    
    public class Action {
        public let text: String
        public var isCancel: Bool
        public let selected: (() -> Void)?
        
        public init(text: String, isCancel: Bool = false, selected: (() -> Void)? = nil) {
            self.text = text
            self.isCancel = isCancel
            self.selected = selected
        }
    }
    
    public let title: String?
    public let message: String?
    public var actions: [Action] = []
    
    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
    }
    
    public func append(_ action: Action) {
        self.actions.append(action)
    }
}



import RxSwift
import RxCocoa


extension Routing {
    
    public func close(animated: Bool) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            self?.closeScene(animated: true) {
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    public func waitEventAndClosePresented<E>(_ eventSource: Observable<E>) -> Observable<E> {
        
        return eventSource
            .observe(on: MainScheduler.instance)
            .flatMap{ [weak self] element -> Observable<E> in
                return self?.close(animated: true).map{ element } ?? .empty()
            }
    }
}

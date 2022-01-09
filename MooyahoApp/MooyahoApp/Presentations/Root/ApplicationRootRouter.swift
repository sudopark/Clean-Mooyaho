//
//  RootRouter.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


public protocol ApplicationRootRouting: Routing {
    
    func routeMain(auth: Auth)
    
    func showNotificationAuthorizationNeedBanner()
    
    func showSharedReadCollection(_ collection: SharedReadCollection)
    
    func showRemindItem(_ itemID: String) -> Bool
}

// MARK: - builders

public typealias ApplicationRootRouterBuildables = MainSceneBuilable

// MARK: - Router

public final class ApplicationRootRouter: Router<ApplicationRootRouterBuildables>, ApplicationRootRouting {

    private var window: UIWindow!
    private weak var mainInteractor: MainSceneInteractable?
}


extension ApplicationRootRouter {
    
    public func routeMain(auth: Auth) {
        
        self.cleanUpWindowIfNeed()
        
        guard let main = self.nextScenesBuilder?.makeMainScene(auth: auth) else { return }
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = main
        self.window.makeKeyAndVisible()
        self.mainInteractor = main.interactor
    }
    
    private func cleanUpWindowIfNeed() {
        guard self.window != nil else { return }
        self.window.rootViewController?.removeFromParent()
        self.window.rootViewController = nil
        self.window.removeFromSuperview()
        self.window = nil
        self.mainInteractor = nil
    }
    
    public func showNotificationAuthorizationNeedBanner() {
        
    }
    
    public func showSharedReadCollection(_ collection: SharedReadCollection) {
        guard let interactor = self.mainInteractor else { return }
        interactor.showSharedReadCollection(collection)
    }
    
    public func showRemindItem(_ itemID: String) -> Bool {
        guard let root = self.window.rootViewController,
              self.mainInteractor != nil
        else {
            return false
        }
        root.dismiss(animated: true) { [weak self] in
            self?.mainInteractor?.showRemindDetail(itemID)
        }
        return true
    }
}

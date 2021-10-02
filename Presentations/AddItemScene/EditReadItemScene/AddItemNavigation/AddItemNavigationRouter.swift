//
//  
//  AddItemNavigationRouter.swift
//  AddItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol AddItemNavigationRouting: Routing {
    
    func prepareNavigation()
    
    func pushToEnterURLScene(_ entered: @escaping (String) -> Void)
    
    func pushConfirmAddLinkItemScene(at collectionID: String?,
                                     url: String,
                                     _ completed: @escaping (ReadLink) -> Void)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias AddItemNavigationRouterBuildables = EnterLinkURLSceneBuilable & EditLinkItemSceneBuilable

public final class AddItemNavigationRouter: Router<AddItemNavigationRouterBuildables>, AddItemNavigationRouting {
    
    private weak var embedNavigationController: BaseNavigationController?
    private var embedNavigationHeightConstranit: NSLayoutConstraint?
}


extension AddItemNavigationRouter {
    
    public func prepareNavigation() {
        guard let scene = self.currentScene as? AddItemNavigationScene else { return }
        let containerView = scene.navigationdContainerView
        
        let navigationController = BaseNavigationController()
        navigationController.shouldHideNavigation = false
        
        scene.addChild(navigationController)
        containerView.addSubview(navigationController.view)
        navigationController.view.autoLayout.fill(containerView)
        self.embedNavigationHeightConstranit = navigationController.view.heightAnchor
            .constraint(equalToConstant: 180)
        self.embedNavigationHeightConstranit?.isActive = true
        navigationController.didMove(toParent: scene)
        self.embedNavigationController = navigationController
    }
    
    // AddItemNavigationRouting implements
    public func pushToEnterURLScene(_ entered: @escaping (String) -> Void) {
        
        guard let navigationController = self.embedNavigationController,
              let next = self.nextScenesBuilder?.makeEnterLinkURLScene(entered) else {
                  return
              }
        navigationController.pushViewController(next, animated: false)
    }
    
    public func pushConfirmAddLinkItemScene(at collectionID: String?,
                                            url: String,
                                            _ completed: @escaping (ReadLink) -> Void) {
        guard let navigationController = self.embedNavigationController,
              let next = self.nextScenesBuilder?.makeEditLinkItemScene(.makeNew(url: url),
                                                                       completed: completed) else {
                  return
              }
        navigationController.pushViewController(next, animated: true)
    }
}

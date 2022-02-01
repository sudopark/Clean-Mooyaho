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
    
    func pushToEnterURLScene(startWith url: String?, _ entered: @escaping (String) -> Void)
    
    func pushConfirmAddLinkItemScene(at collectionID: String?, url: String)
    func popToEnrerURLScene()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias AddItemNavigationRouterBuildables = EnterLinkURLSceneBuilable & EditLinkItemSceneBuilable

public final class AddItemNavigationRouter: Router<AddItemNavigationRouterBuildables>, AddItemNavigationRouting {
    
    private weak var embedNavigationController: BaseNavigationController?
    private var embedNavigationHeightConstranit: NSLayoutConstraint?
}


extension AddItemNavigationRouter {
    
    private var currentInteractor: AddItemNavigationSceneInteractable? {
        return (self.currentScene as? AddItemNavigationScene)?.interactor
    }
    
    private var childSceneHeight: CGFloat {
        return 400
    }
    
    public func prepareNavigation() {
        guard let scene = self.currentScene as? AddItemNavigationScene else { return }
        let containerView = scene.navigationdContainerView
        
        let navigationController = BaseNavigationController(shouldHideNavigation: false)
        
        scene.addChild(navigationController)
        containerView.addSubview(navigationController.view)
        navigationController.view.autoLayout.fill(containerView)
        self.embedNavigationHeightConstranit = navigationController.view.heightAnchor
            .constraint(equalToConstant: childSceneHeight)
        self.embedNavigationHeightConstranit?.isActive = true
        navigationController.didMove(toParent: scene)
        self.embedNavigationController = navigationController
    }
    
    // AddItemNavigationRouting implements
    public func pushToEnterURLScene(startWith url: String?, _ entered: @escaping (String) -> Void) {
        
        guard let navigationController = self.embedNavigationController,
              let next = self.nextScenesBuilder?.makeEnterLinkURLScene(startWith: url, entered) else {
                  return
              }
        navigationController.pushViewController(next, animated: false)
    }
    
    public func pushConfirmAddLinkItemScene(at collectionID: String?, url: String) {
        
        guard let navigationController = self.embedNavigationController,
              let next = self.nextScenesBuilder?.makeEditLinkItemScene(.makeNew(url: url),
                                                                       collectionID: collectionID,
                                                                       listener: self.currentInteractor) else {
                  return
              }
        navigationController.pushViewController(next, animated: true)
    }
    
    public func popToEnrerURLScene() {
        
        self.embedNavigationController?.popViewController(animated: true)
    }
}

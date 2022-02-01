//
//  
//  SharedMemberListRouter.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2022/01/01.
//
//  DiscoveryScene
//
//  Created sudo.park on 2022/01/01.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SharedMemberListRouting: Routing {
    
    func showMemberProfile(_ memberID: String)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SharedMemberListRouterBuildables = MemberProfileSceneBuilable

public final class SharedMemberListRouter: Router<SharedMemberListRouterBuildables>, SharedMemberListRouting { }


extension SharedMemberListRouter {
    
    // SharedMemberListRouting implements
    private var currentInteractor: SharedMemberListSceneInteractable? {
        return (self.currentScene as? SharedMemberListScene)?.interactor
    }
    
    public func showMemberProfile(_ memberID: String) {
        guard let next = self.nextScenesBuilder?.makeMemberProfileScene(memberID: memberID, listener: nil)
        else {
            return
        }
        let navigationController = BaseNavigationController(
            rootViewController: next,
            shouldHideNavigation: false,
            shouldShowCloseButtonIfNeed: true
        )
        self.currentBaseViewControllerScene?.presentPageSheetOrFullScreen(navigationController, animated: true)
    }
}

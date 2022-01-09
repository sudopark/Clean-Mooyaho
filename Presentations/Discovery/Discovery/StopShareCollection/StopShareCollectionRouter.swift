//
//  
//  StopShareCollectionRouter.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/16.
//
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol StopShareCollectionRouting: Routing {
    
    func presentShareSheet(with url: String)
    
    func findWhoSharedReadCollection(_ sharedCollection: SharedReadCollection,
                                     memberIDs: [String])
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias StopShareCollectionRouterBuildables = SharedMemberListSceneBuilable

public final class StopShareCollectionRouter: Router<StopShareCollectionRouterBuildables>, StopShareCollectionRouting { }


extension StopShareCollectionRouter {
    
    // StopShareCollectionRouting implements
    private var currentInteractor: StopShareCollectionSceneInteractable? {
        return (self.currentScene as? StopShareCollectionScene)?.interactor
    }
    
    public func presentShareSheet(with url: String) {
        guard let url = URL(string: url) else { return }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.currentScene?.present(activity, animated: true, completion: nil)
    }
    
    public func findWhoSharedReadCollection(_ sharedCollection: SharedReadCollection,
                                            memberIDs: [String]) {
        
        guard let next = self.nextScenesBuilder?.makeSharedMemberListScene(
            sharedCollection: sharedCollection,
            memberIDs: memberIDs,
            listener: self.currentInteractor
        )
        else {
            return
        }
        let navigationController = BaseNavigationController(rootViewController: next)
        navigationController.shouldHideNavigation = false
        self.currentScene?.present(navigationController, animated: true, completion: nil)
    }
}

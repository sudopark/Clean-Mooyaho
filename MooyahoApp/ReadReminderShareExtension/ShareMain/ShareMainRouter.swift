//
//  
//  ShareMainRouter.swift
//  ReadReminderShareExtension
//
//  Created by sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol ShareMainRouting: Routing {
    
    func showEditScene(_ url: String)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias ShareMainRouterBuildables = EditLinkItemSceneBuilable

public final class ShareMainRouter: Router<ShareMainRouterBuildables>, ShareMainRouting { }


extension ShareMainRouter {
    
    // ShareMainRouting implements
    private var currentInteractor: ShareMainSceneInteractable? {
        return (self.currentScene as? ShareMainScene)?.interactor
    }
    
    public func showEditScene(_ url: String) {
        
        let editCase: EditLinkItemCase = .makeNew(url: url)
        guard let next = self.nextScenesBuilder?
                .makeEditLinkItemScene(editCase, collectionID: nil, listener: self.currentInteractor)
        else { return }
        next.setupUIForShareExtension()
        self.currentScene?.present(next, animated: true, completion: nil)
    }
}

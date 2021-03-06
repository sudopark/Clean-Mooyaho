//
//  
//  EditReadRemindRouter.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/22.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditReadRemindRouting: Routing {
    
    func openAlertSetting()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditReadRemindRouterBuildables = EmptyBuilder

public final class EditReadRemindRouter: Router<EditReadRemindRouterBuildables>, EditReadRemindRouting { }


extension EditReadRemindRouter {
    
    // EditReadRemindRouting implements
    private var currentInteractor: EditReadRemindSceneInteractable? {
        return (self.currentScene as? EditReadRemindScene)?.interactor
    }
    
    public func openAlertSetting() {
        
        guard let appSettings = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(appSettings)
        else { return }
        
        UIApplication.shared.open(appSettings)
    }
}

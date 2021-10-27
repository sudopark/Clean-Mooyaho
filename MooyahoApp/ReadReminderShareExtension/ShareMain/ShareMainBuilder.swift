//
//  
//  ShareMainBuilder.swift
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


// MARK: - Builder + DependencyInjector Extension

public protocol ShareMainSceneBuilable {
    
    func makeShareMainScene(listener: ShareMainSceneListenable?) -> ShareMainScene
}


extension SharedDependencyInjecttor: ShareMainSceneBuilable {
    
    public func makeShareMainScene(listener: ShareMainSceneListenable?) -> ShareMainScene {
        let viewController = ShareMainViewController()
        return viewController
    }
}

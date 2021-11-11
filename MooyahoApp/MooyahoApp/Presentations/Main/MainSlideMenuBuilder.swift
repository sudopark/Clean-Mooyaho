//
//  
//  MainSlideMenuBuilder.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol MainSlideMenuSceneBuilable {
    
    func makeMainSlideMenuScene(listener: MainSlideMenuSceneListenable?) -> MainSlideMenuScene
}

extension MainSlideMenuViewModelImple: MainSlideMenuSceneInteractor { }

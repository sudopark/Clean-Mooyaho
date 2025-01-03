//
//  
//  MainBuilder.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DI Container Extension

@MainActor
public protocol MainSceneBuilable {
    
    func makeMainScene(auth: Auth) -> MainScene
}

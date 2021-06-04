//
//  
//  NearbyBuilder.swift
//  LocationScenes
//
//  Created by sudo.park on 2021/05/22.
//
//  LocationScenes
//
//  Created sudo.park on 2021/05/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol NearbySceneBuilable {
    
    func makeNearbyScene() -> NearbyScene
}

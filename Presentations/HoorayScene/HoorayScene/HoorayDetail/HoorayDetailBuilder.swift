//
//  
//  HoorayDetailBuilder.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/08/26.
//
//  HoorayScene
//
//  Created sudo.park on 2021/08/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol HoorayDetailSceneBuilable {
    
    func makeHoorayDetailScene() -> HoorayDetailScene
}

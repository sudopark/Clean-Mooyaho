//
//  
//  MakeHoorayBuilder.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/04.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol MakeHooraySceneBuilable {
    
    func makeMakeHoorayScene() -> MakeHoorayScene
}

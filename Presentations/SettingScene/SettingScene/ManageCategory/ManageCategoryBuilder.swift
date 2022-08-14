//
//  
//  ManageCategoryBuilder.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/03.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol ManageCategorySceneBuilable {
    
    func makeManageCategoryScene(listener: ManageCategorySceneListenable?) -> ManageCategoryScene
}

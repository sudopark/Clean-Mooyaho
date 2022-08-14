//
//  
//  ManageAccountBuilder.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/06.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol ManageAccountSceneBuilable {
    
    func makeManageAccountScene(listener: ManageAccountSceneListenable?) -> ManageAccountScene
}

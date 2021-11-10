//
//  Builders+Setting.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/11.
//

import UIKit


// MARK: - Builder + DependencyInjector Extension

public protocol SettingMainSceneBuilable {
    
    func makeSettingMainScene(listener: SettingMainSceneListenable?) -> SettingMainScene
}


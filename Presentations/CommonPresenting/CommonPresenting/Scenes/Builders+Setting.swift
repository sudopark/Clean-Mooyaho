//
//  Builders+Setting.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/11.
//

import UIKit


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol SettingMainSceneBuilable {
    
    func makeSettingMainScene(listener: SettingMainSceneListenable?) -> SettingMainScene
}


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol WaitMigrationSceneBuilable {
    
    func makeWaitMigrationScene(userID: String,
                                shouldResume: Bool,
                                listener: WaitMigrationSceneListenable?) -> WaitMigrationScene
}

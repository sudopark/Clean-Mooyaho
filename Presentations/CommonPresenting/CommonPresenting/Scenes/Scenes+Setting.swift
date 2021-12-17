//
//  Scenes+Setting.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/11.
//

import UIKit

import Domain


// MARK: - SettingMainScene Interactable & Listenable

public protocol SettingMainSceneInteractable: SignInSceneListenable { }

public protocol SettingMainSceneListenable: AnyObject {
    
    func settingMain(didCompleteSignedIn member: Member)
}


// MARK: - SettingMainScene

public protocol SettingMainScene: Scenable {
    
    var interactor: SettingMainSceneInteractable? { get }
}


// MARK: - WaitMigrationScene Interactable & Listenable

public protocol WaitMigrationSceneInteractable { }

public protocol WaitMigrationSceneListenable: AnyObject { }


// MARK: - WaitMigrationScene

public protocol WaitMigrationScene: Scenable {
    
    var interactor: WaitMigrationSceneInteractable? { get }
}

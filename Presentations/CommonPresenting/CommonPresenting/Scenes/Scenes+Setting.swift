//
//  Scenes+Setting.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/11.
//

import UIKit

import Domain


// MARK: - SettingMainScene Interactable & Listenable

public protocol SettingMainSceneInteractable: Sendable { }

public protocol SettingMainSceneListenable: Sendable, AnyObject { }


// MARK: - SettingMainScene

public protocol SettingMainScene: Scenable {
    
    nonisolated var interactor: SettingMainSceneInteractable? { get }
}


// MARK: - WaitMigrationScene Interactable & Listenable

public protocol WaitMigrationSceneInteractable: Sendable { }

public protocol WaitMigrationSceneListenable: Sendable, AnyObject { }


// MARK: - WaitMigrationScene

public protocol WaitMigrationScene: Scenable {
    
    nonisolated var interactor: WaitMigrationSceneInteractable? { get }
}

//
//  Scenes+Setting.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/11.
//

import UIKit

import Domain


// MARK: - SettingMainScene Interactable & Listenable

public protocol SettingMainSceneInteractable { }

public protocol SettingMainSceneListenable: AnyObject { }


// MARK: - SettingMainScene

public protocol SettingMainScene: Scenable {
    
    var interactor: SettingMainSceneInteractable? { get }
}


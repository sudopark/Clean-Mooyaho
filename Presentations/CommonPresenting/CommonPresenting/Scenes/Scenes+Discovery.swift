//
//  Scenes+Discovery.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/14.
//

import UIKit

import Domain


// MARK: - DiscoveryMainScene Interactable & Listenable

public protocol DiscoveryMainSceneInteractable { }

public protocol DiscoveryMainSceneListenable: AnyObject {
    
    func switchCollectionRequested()
}


// MARK: - DiscoveryMainScene

public protocol DiscoveryMainScene: Scenable {
    
    var interactor: DiscoveryMainSceneInteractable? { get }
}
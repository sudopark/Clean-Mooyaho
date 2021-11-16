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


// MARK: - StopShareCollectionScene Interactable & Listenable

public protocol StopShareCollectionSceneInteractable { }

public protocol StopShareCollectionSceneListenable: AnyObject { }


// MARK: - StopShareCollectionScene

public protocol StopShareCollectionScene: Scenable {
    
    var interactor: StopShareCollectionSceneInteractable? { get }
}


// MARK: - SharedCollectionItemsScene Interactable & Listenable

public protocol SharedCollectionItemsSceneInteractable { }

public protocol SharedCollectionItemsSceneListenable: AnyObject { }


// MARK: - SharedCollectionItemsScene

public protocol SharedCollectionItemsScene: Scenable {
    
    var interactor: SharedCollectionItemsSceneInteractable? { get }
}

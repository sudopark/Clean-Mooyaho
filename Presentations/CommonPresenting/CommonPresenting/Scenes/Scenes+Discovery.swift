//
//  Scenes+Discovery.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/14.
//

import UIKit

import Domain


// MARK: - DiscoveryMainScene Interactable & Listenable

public protocol DiscoveryMainSceneInteractable: Sendable { }

public protocol DiscoveryMainSceneListenable: Sendable, AnyObject {
    
    func switchCollectionRequested()
}


// MARK: - DiscoveryMainScene

public protocol DiscoveryMainScene: Scenable {
    
    nonisolated var interactor: DiscoveryMainSceneInteractable? { get }
}


// MARK: - StopShareCollectionScene Interactable & Listenable

public protocol StopShareCollectionSceneInteractable: Sendable, SharedMemberListSceneListenable { }

public protocol StopShareCollectionSceneListenable: Sendable, AnyObject { }


// MARK: - StopShareCollectionScene

public protocol StopShareCollectionScene: Scenable {
    
    nonisolated var interactor: StopShareCollectionSceneInteractable? { get }
}


// MARK: - SharedCollectionItemsScene Interactable & Listenable

public protocol SharedCollectionItemsSceneInteractable: Sendable { }

public protocol SharedCollectionItemsSceneListenable: Sendable, AnyObject { }


// MARK: - SharedCollectionItemsScene

public protocol SharedCollectionItemsScene: Scenable {
    
    nonisolated var interactor: SharedCollectionItemsSceneInteractable? { get }
}


// MARK: - SharedCollectionInfoDialogScene Interactable & Listenable

public protocol SharedCollectionInfoDialogSceneInteractable: Sendable { }

public protocol SharedCollectionInfoDialogSceneListenable: Sendable, AnyObject {
    
    func sharedCollectionDidRemoved(_ sharedID: String)
}

// MARK: - SharedCollectionInfoDialogScene

public protocol SharedCollectionInfoDialogScene: Scenable {
    
    nonisolated var interactor: SharedCollectionInfoDialogSceneInteractable? { get }
}


// MARK: - SharedMemberListScene Interactable & Listenable

public protocol SharedMemberListSceneInteractable: Sendable { }

public protocol SharedMemberListSceneListenable: Sendable, AnyObject {
    
    func sharedMemberListDidExcludeMember(_ memberID: String)
}


// MARK: - SharedMemberListScene

public protocol SharedMemberListScene: Scenable {
    
    nonisolated var interactor: SharedMemberListSceneInteractable? { get }
}

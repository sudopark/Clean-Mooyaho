//
//  Scenes+ReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import RxSwift

import Domain


// MARK: - CollectionNavigating

public enum CollectionRoot {
    case myCollections
    case sharedCollection(SharedReadCollection)
}

public protocol ReadCollectionNavigateListenable: Sendable, AnyObject {
    
    func readCollection(didChange root: CollectionRoot)
    
    func readCollection(didShowMy subCollectionID: String?)
    
    func readCollection(didShowShared subCollectionID: String)
}

extension ReadCollectionNavigateListenable {
    
    public func readCollection(didChange root: CollectionRoot) { }
 
    public func readCollection(didShowMy subCollectionID: String?) { }
    
    public func readCollection(didShowShared subCollectionID: String) { }
}

// MARK: - ReadCollectionMainScene Input & Output

public protocol ReadCollectionMainSceneInteractable: Sendable, AnyObject {
    
    func addNewCollectionItem()
    
    func addNewReadLinkItem()
    
    func addNewReaedLinkItem(with url: String)
    
    func switchToSharedCollection(_ collection: SharedReadCollection)
    
    func switchToMyReadCollections()
    
    func jumpToCollection(_ collectionID: String?)
    
    var rootType: CollectionRoot { get }
}

public protocol ReadCollectionMainSceneListenable: Sendable { }


// MARK: - ReadCollectionMainScene

public protocol ReadCollectionMainScene: Scenable {
    
    nonisolated var interactor: ReadCollectionMainSceneInteractable? { get }
}


// MARK: - ReadCollectionScene

public protocol ReadCollectionItemsSceneInteractable: Sendable, EditReadCollectionSceneListenable, AddItemNavigationSceneListenable, EditLinkItemSceneListenable, EditReadRemindSceneListenable {
    
    func addNewCollectionItem()
    
    func addNewReadLinkItem()
    
    func addNewReadLinkItem(using url: String)
}

// MARK: - ReadCollectionScene

public protocol ReadCollectionScene: Scenable {
    
    nonisolated var interactor: ReadCollectionItemsSceneInteractable? { get }
}


// MARK: - SelectAddItemTypeScene Input & Output

public protocol SelectAddItemTypeSceneInput: Sendable { }

public protocol SelectAddItemTypeSceneOutput: Sendable { }


// MARK: - SelectAddItemTypeScene

public protocol SelectAddItemTypeScene: Scenable, PangestureDismissableScene {
    
    nonisolated var input: SelectAddItemTypeSceneInput? { get }

    nonisolated var output: SelectAddItemTypeSceneOutput? { get }
}


// MARK: - NavigateCollectionScene Interactable & Listenable

public protocol NavigateCollectionSceneInteractable: Sendable { }

public protocol NavigateCollectionSceneListenable: Sendable, AnyObject {
    
    func navigateCollection(didSelectCollection collection: ReadCollection?)
}

extension NavigateCollectionSceneListenable {
    
    public func navigateCollection(didSelectCollection collection: ReadCollection?) { }
}


// MARK: - NavigateCollectionScene

public protocol NavigateCollectionScene: Scenable {
    
    nonisolated var interactor: NavigateCollectionSceneInteractable? { get }
}


// MARK: - FavoriteItemsScene Interactable & Listenable

public protocol FavoriteItemsSceneInteractable: Sendable, InnerWebViewSceneListenable { }

public protocol FavoriteItemsSceneListenable: Sendable, AnyObject {
    
    func favoriteItemsScene(didRequestJump collectionID: String?)
}


// MARK: - FavoriteItemsScene

public protocol FavoriteItemsScene: Scenable {
    
    nonisolated var interactor: FavoriteItemsSceneInteractable? { get }
}

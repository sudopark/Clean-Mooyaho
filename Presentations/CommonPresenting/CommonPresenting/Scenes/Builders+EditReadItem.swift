//
//  Builders+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import Foundation

import Domain


// MARK: - Builder + DependencyInjector Extension

public protocol SelectAddItemTypeSceneBuilable {
    
    func makeSelectAddItemTypeScene(_ completed: @escaping (Bool) -> Void) -> SelectAddItemTypeScene
}


// MARK: - AddItemNavigationSceneBuilable

public protocol AddItemNavigationSceneBuilable {
    
    func makeAddItemNavigationScene(at collectionID: String?,
                                    _ listener: AddItemNavigationSceneListenable?) -> AddItemNavigationScene
}


// MARK: - EditLinkItemSceneBuilable

public enum EditLinkItemCase {
    case makeNew( url: String)
    case edit(item: ReadLink)
}

public protocol EditLinkItemSceneBuilable {
    
    func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                               collectionID: String?,
                               listener: EditLinkItemSceneListenable?) -> EditLinkItemScene
}


// MARK: - EditCollectionCase

public enum EditCollectionCase {
    case makeNew
    case edit(ReadCollection)
}

public protocol EditReadCollectionSceneBuilable {
    
    func makeEditReadCollectionScene(parentID: String?,
                                     editCase: EditCollectionCase,
                                     listener: EditReadCollectionSceneListenable?) -> EditReadCollectionScene
}

// MARK: - EditReadPriorityScene Interactable & Listenable

public protocol EditReadPrioritySceneInteractable { }

public protocol EditReadPrioritySceneListenable: AnyObject { }

public protocol ReadPrioritySelectListenable: EditReadPrioritySceneListenable {

    func editReadPriority(didSelect priority: ReadPriority)
}

public protocol ReadPriorityUpdateListenable: EditReadPrioritySceneListenable {
    
    func editReadPriority(didUpdate priority: ReadPriority, for item: ReadItem)
}


// MARK: - EditReadPriorityScene

public protocol EditReadPriorityScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditReadPrioritySceneInteractable? { get }
}

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
                                    _ completed: @escaping (ReadLink) -> Void) -> AddItemNavigationScene
}


// MARK: - Builder + DependencyInjector Extension

public enum EditCollectionCase {
    case makeNew
    case edit(ReadCollection)
}

public protocol EditReadCollectionSceneBuilable {
    
    func makeEditReadCollectionScene(parentID: String?,
                                     editCase: EditCollectionCase,
                                     completed: @escaping (ReadCollection) -> Void) -> EditReadCollectionScene
}

// MARK: - EditReadPriorityScene Interactable & Listenable

public protocol EditReadPrioritySceneInteractable { }

public protocol EditReadPrioritySceneListenable: AnyObject { }


// MARK: - EditReadPriorityScene

public protocol EditReadPriorityScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditReadPrioritySceneInteractable? { get }
}

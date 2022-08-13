//
//  Builders+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import Foundation

import Domain
import Extensions


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol SelectAddItemTypeSceneBuilable {
    
    func makeSelectAddItemTypeScene(_ completed: @escaping (Bool) -> Void) -> SelectAddItemTypeScene
}


// MARK: - AddItemNavigationSceneBuilable

@MainActor
public protocol AddItemNavigationSceneBuilable {
    
    func makeAddItemNavigationScene(at collectionID: String?,
                                    startWith: String?,
                                    _ listener: AddItemNavigationSceneListenable?) -> AddItemNavigationScene
}


// MARK: - EditLinkItemSceneBuilable

public enum EditLinkItemCase {
    case makeNew( url: String)
    case edit(item: ReadLink)
}

@MainActor
public protocol EditLinkItemSceneBuilable {
    
    func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                               collectionID: String?,
                               listener: EditLinkItemSceneListenable?) -> EditLinkItemScene
}


// MARK: - EditCollectionCase

public enum EditCollectionCase: Sendable {
    case makeNew
    case edit(ReadCollection)
}

@MainActor
public protocol EditReadCollectionSceneBuilable {
    
    func makeEditReadCollectionScene(parentID: String?,
                                     editCase: EditCollectionCase,
                                     listener: EditReadCollectionSceneListenable?) -> EditReadCollectionScene
}

// MARK: - EditReadPriorityScene Interactable & Listenable

public protocol EditReadPrioritySceneInteractable: Sendable { }

public protocol EditReadPrioritySceneListenable: Sendable, AnyObject { }

public protocol ReadPrioritySelectListenable: Sendable, EditReadPrioritySceneListenable {

    func editReadPriority(didSelect priority: ReadPriority)
}

public protocol ReadPriorityUpdateListenable: Sendable, EditReadPrioritySceneListenable {
    
    func editReadPriority(didUpdate priority: ReadPriority, for item: ReadItem)
}

// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol EditItemsCustomOrderSceneBuilable {
    
    func makeEditItemsCustomOrderScene(collectionID: String?,
                                       listener: EditItemsCustomOrderSceneListenable?) -> EditItemsCustomOrderScene
}


// MARK: - Builder + DependencyInjector Extension

public enum EditRemindCase {
    case select(startWith: TimeStamp?)
    case edit(_ item: ReadItem)
}

@MainActor
public protocol EditReadRemindSceneBuilable {
    
    func makeEditReadRemindScene(_ editCase: EditRemindCase,
                                 listener: EditReadRemindSceneListenable?) -> EditReadRemindScene
}

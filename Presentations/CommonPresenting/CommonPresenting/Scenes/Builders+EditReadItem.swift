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

public protocol SelectAddItemTypeSceneBuilable {
    
    func makeSelectAddItemTypeScene(_ completed: @escaping (Bool) -> Void) -> SelectAddItemTypeScene
}


// MARK: - AddItemNavigationSceneBuilable

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

// MARK: - Builder + DependencyInjector Extension

public protocol EditItemsCustomOrderSceneBuilable {
    
    func makeEditItemsCustomOrderScene(collectionID: String?,
                                       listener: EditItemsCustomOrderSceneListenable?) -> EditItemsCustomOrderScene
}


// MARK: - Builder + DependencyInjector Extension

public enum EditRemindCase {
    case select(startWith: TimeStamp?)
    case edit(_ item: ReadItem)
}

public protocol EditReadRemindSceneBuilable {
    
    func makeEditReadRemindScene(_ editCase: EditRemindCase,
                                 listener: EditReadRemindSceneListenable?) -> EditReadRemindScene
}

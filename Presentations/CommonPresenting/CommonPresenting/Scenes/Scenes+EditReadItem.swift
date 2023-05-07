//
//  Scenes+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import UIKit

import Domain


public protocol AddItemNavigationSceneInteractable: Sendable, EditLinkItemSceneListenable {
    
    func requestpopToEnrerURLScene()
}

public protocol AddItemNavigationSceneListenable: Sendable, AnyObject {
    
    func addReadLink(didAdded newItem: ReadLink)
}

// MARK: - AddItemNavigationScene

public protocol AddItemNavigationScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: AddItemNavigationSceneInteractable? { get }
    
    var navigationdContainerView: UIView { get }
}


// MARK: - EnterLinkURLScene Input & Output

public protocol EnterLinkURLSceneInput: Sendable { }

public protocol EnterLinkURLSceneOutput: Sendable { }


// MARK: - EnterLinkURLScene

public protocol EnterLinkURLScene: Scenable {
    
    nonisolated var input: EnterLinkURLSceneInput? { get }

    nonisolated var output: EnterLinkURLSceneOutput? { get }
}

// MARK: - EditLinkItemScene interactor

public protocol EditLinkItemSceneInteractable: Sendable, ReadPrioritySelectListenable, EditCategorySceneListenable, EditReadRemindSceneListenable, NavigateCollectionSceneListenable { }

public protocol EditLinkItemSceneListenable: Sendable, AnyObject {
    
    func editReadLink(didEdit item: ReadLink)
    
    func editReadLinkDidDismissed()
}

extension EditLinkItemSceneListenable {
    
    public func editReadLinkDidDismissed() { }
}

// MARK: - EditLinkItemScene

public protocol EditLinkItemScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: EditLinkItemSceneInteractable? { get }
    
    nonisolated func setupUIForShareExtension()
}

// MARK: - EditReadCollectionScene Input & Output

public protocol EditReadCollectionSceneInteractable: Sendable, ReadPrioritySelectListenable, EditCategorySceneListenable, EditReadRemindSceneListenable, NavigateCollectionSceneListenable { }

public protocol EditReadCollectionSceneListenable: Sendable, AnyObject {
    
    func editReadCollection(didChange collection: ReadCollection)
}

// MARK: - EditReadCollectionScene

public protocol EditReadCollectionScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: EditReadCollectionSceneInteractable? { get }
}


// MARK: - EditCategoryScene Interactable & Listenable

public protocol EditCategorySceneInteractable: Sendable, ColorSelectSceneListenable { }

public protocol EditCategorySceneListenable: Sendable, AnyObject {
    
    func editCategory(didSelect categories: [ItemCategory])
}


// MARK: - EditCategoryScene

public protocol EditCategoryScene: Scenable {
    
    nonisolated var interactor: EditCategorySceneInteractable? { get }
}


// MARK: - EditItemsCustomOrderScene Interactable & Listenable

public protocol EditItemsCustomOrderSceneInteractable: Sendable { }

public protocol EditItemsCustomOrderSceneListenable: Sendable, AnyObject { }


// MARK: - EditItemsCustomOrderScene

public protocol EditItemsCustomOrderScene: Scenable {
    
    nonisolated var interactor: EditItemsCustomOrderSceneInteractable? { get }
}


// MARK: - EditReadRemindScene Interactable & Listenable

public protocol EditReadRemindSceneInteractable: Sendable { }

public protocol EditReadRemindSceneListenable: Sendable, AnyObject {
    
    func editReadRemind(didSelect time: Date?)
    
    func editReadRemind(didUpdate item: ReadItem)
}

extension EditReadRemindSceneListenable {
    
    public func editReadRemind(didSelect time: Date?) { }
    
    public func editReadRemind(didUpdate item: ReadItem) { }
}


// MARK: - EditReadPriorityScene

public protocol EditReadPriorityScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: EditReadPrioritySceneInteractable? { get }
}

// MARK: - EditReadRemindScene

public protocol EditReadRemindScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: EditReadRemindSceneInteractable? { get }
}

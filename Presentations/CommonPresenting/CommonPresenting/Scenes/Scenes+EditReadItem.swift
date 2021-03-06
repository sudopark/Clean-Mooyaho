//
//  Scenes+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import UIKit

import Domain


public protocol AddItemNavigationSceneInteractable: EditLinkItemSceneListenable {
    
    func requestpopToEnrerURLScene()
}

public protocol AddItemNavigationSceneListenable: AnyObject {
    
    func addReadLink(didAdded newItem: ReadLink)
}

// MARK: - AddItemNavigationScene

public protocol AddItemNavigationScene: Scenable, PangestureDismissableScene {
    
    var interactor: AddItemNavigationSceneInteractable? { get }
    
    var navigationdContainerView: UIView { get }
}


// MARK: - EnterLinkURLScene Input & Output

public protocol EnterLinkURLSceneInput { }

public protocol EnterLinkURLSceneOutput { }


// MARK: - EnterLinkURLScene

public protocol EnterLinkURLScene: Scenable {
    
    var input: EnterLinkURLSceneInput? { get }

    var output: EnterLinkURLSceneOutput? { get }
}

// MARK: - EditLinkItemScene interactor

public protocol EditLinkItemSceneInteractable: ReadPrioritySelectListenable, EditCategorySceneListenable, EditReadRemindSceneListenable, NavigateCollectionSceneListenable { }

public protocol EditLinkItemSceneListenable: AnyObject {
    
    func editReadLink(didEdit item: ReadLink)
    
    func editReadLinkDidDismissed()
}

extension EditLinkItemSceneListenable {
    
    public func editReadLinkDidDismissed() { }
}

// MARK: - EditLinkItemScene

public protocol EditLinkItemScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditLinkItemSceneInteractable? { get }
    
    func setupUIForShareExtension()
}

// MARK: - EditReadCollectionScene Input & Output

public protocol EditReadCollectionSceneInteractable: ReadPrioritySelectListenable, EditCategorySceneListenable, EditReadRemindSceneListenable, NavigateCollectionSceneListenable { }

public protocol EditReadCollectionSceneListenable: AnyObject {
    
    func editReadCollection(didChange collection: ReadCollection)
}

// MARK: - EditReadCollectionScene

public protocol EditReadCollectionScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditReadCollectionSceneInteractable? { get }
}


// MARK: - EditCategoryScene Interactable & Listenable

public protocol EditCategorySceneInteractable: ColorSelectSceneListenable { }

public protocol EditCategorySceneListenable: AnyObject {
    
    func editCategory(didSelect categories: [ItemCategory])
}


// MARK: - EditCategoryScene

public protocol EditCategoryScene: Scenable {
    
    var interactor: EditCategorySceneInteractable? { get }
}


// MARK: - EditItemsCustomOrderScene Interactable & Listenable

public protocol EditItemsCustomOrderSceneInteractable { }

public protocol EditItemsCustomOrderSceneListenable: AnyObject { }


// MARK: - EditItemsCustomOrderScene

public protocol EditItemsCustomOrderScene: Scenable {
    
    var interactor: EditItemsCustomOrderSceneInteractable? { get }
}


// MARK: - EditReadRemindScene Interactable & Listenable

public protocol EditReadRemindSceneInteractable { }

public protocol EditReadRemindSceneListenable: AnyObject {
    
    func editReadRemind(didSelect time: Date?)
    
    func editReadRemind(didUpdate item: ReadItem)
}

extension EditReadRemindSceneListenable {
    
    public func editReadRemind(didSelect time: Date?) { }
    
    public func editReadRemind(didUpdate item: ReadItem) { }
}


// MARK: - EditReadPriorityScene

public protocol EditReadPriorityScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditReadPrioritySceneInteractable? { get }
}

// MARK: - EditReadRemindScene

public protocol EditReadRemindScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditReadRemindSceneInteractable? { get }
}

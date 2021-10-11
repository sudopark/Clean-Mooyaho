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

public protocol EditLinkItemSceneInteractable: ReadPrioritySelectListenable, EditCategorySceneListenable { }

public protocol EditLinkItemSceneListenable: AnyObject {
    
    func editReadLink(didEdit item: ReadLink)
}

// MARK: - EditLinkItemScene

public protocol EditLinkItemScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditLinkItemSceneInteractable? { get }
}

// MARK: - EditReadCollectionScene Input & Output

public protocol EditReadCollectionSceneInteractable: ReadPrioritySelectListenable, EditCategorySceneListenable { }

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

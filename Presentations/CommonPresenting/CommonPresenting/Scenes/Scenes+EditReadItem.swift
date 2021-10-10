//
//  Scenes+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import UIKit

import Domain


// MARK: - AddItemNavigationScene Input & Output

public protocol AddItemNavigationSceneInput {
    
    func requestpopToEnrerURLScene()
}

public protocol AddItemNavigationSceneOutput { }


// MARK: - AddItemNavigationScene

public protocol AddItemNavigationScene: Scenable, PangestureDismissableScene {
    
    var input: AddItemNavigationSceneInput? { get }

    var output: AddItemNavigationSceneOutput? { get }
    
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


// MARK: - EditLinkItemScene

public protocol EditLinkItemScene: Scenable {
    
    var interactor: EditLinkItemSceneInteractable? { get }
}

// MARK: - EditReadCollectionScene Input & Output

public protocol EditReadCollectionSceneInteractable: ReadPrioritySelectListenable, EditCategorySceneListenable { }

// MARK: - EditReadCollectionScene

public protocol EditReadCollectionScene: Scenable, PangestureDismissableScene {
    
    var interactor: EditReadCollectionSceneInteractable? { get }
}


// MARK: - EditCategoryScene Interactable & Listenable

public protocol EditCategorySceneInteractable { }

public protocol EditCategorySceneListenable: AnyObject {
    
    func editCategory(didSelect categories: [ItemCategory])
}


// MARK: - EditCategoryScene

public protocol EditCategoryScene: Scenable {
    
    var interactor: EditCategorySceneInteractable? { get }
}

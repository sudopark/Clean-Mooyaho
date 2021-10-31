//
//  Scenes+ReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import RxSwift

import Domain

// MARK: - ReadCollectionMainScene Input & Output

public protocol ReadCollectionMainSceneInteractable: AnyObject {
    
    func addNewCollectionItem()
    
    func addNewReadLinkItem()
    
    func addNewReaedLinkItem(with url: String)
}

public protocol ReadCollectionMainSceneListenable { }


// MARK: - ReadCollectionMainScene

public protocol ReadCollectionMainScene: Scenable {
    
    var interactor: ReadCollectionMainSceneInteractable? { get }
}


// MARK: - ReadCollectionScene

public protocol ReadCollectionItemsSceneInteractable: EditReadCollectionSceneListenable, AddItemNavigationSceneListenable, EditLinkItemSceneListenable, EditReadRemindSceneListenable {
    
    func addNewCollectionItem()
    
    func addNewReadLinkItem()
    
    func addNewReadLinkItem(using url: String)
}

// MARK: - ReadCollectionScene

public protocol ReadCollectionScene: Scenable {
    
    var interactor: ReadCollectionItemsSceneInteractable? { get }
}


// MARK: - SelectAddItemTypeScene Input & Output

public protocol SelectAddItemTypeSceneInput { }

public protocol SelectAddItemTypeSceneOutput { }


// MARK: - SelectAddItemTypeScene

public protocol SelectAddItemTypeScene: Scenable, PangestureDismissableScene {
    
    var input: SelectAddItemTypeSceneInput? { get }

    var output: SelectAddItemTypeSceneOutput? { get }
}


// MARK: - NavigateCollectionScene Interactable & Listenable

public protocol NavigateCollectionSceneInteractable { }

public protocol NavigateCollectionSceneListenable: AnyObject {
    
    func navigateCollection(didSelectCollection collection: ReadCollection?)
}

extension NavigateCollectionSceneListenable {
    
    public func navigateCollection(didSelectCollection collection: ReadCollection?) { }
}


// MARK: - NavigateCollectionScene

public protocol NavigateCollectionScene: Scenable {
    
    var interactor: NavigateCollectionSceneInteractable? { get }
}

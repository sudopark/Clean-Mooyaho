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

public protocol ReadCollectionMainSceneInput: AnyObject {
    
    func addNewCollectionItem()
    
    func addNewReadLinkItem()
}

public protocol ReadCollectionMainSceneOutput { }


// MARK: - ReadCollectionMainScene

public protocol ReadCollectionMainScene: Scenable {
    
    var input: ReadCollectionMainSceneInput? { get }

    var output: ReadCollectionMainSceneOutput? { get }
}


// MARK: - ReadCollectionScene

public protocol ReadCollectionItemsSceneInteractable: EditReadCollectionSceneListenable, AddItemNavigationSceneListenable, EditLinkItemSceneListenable {
    
    func addNewCollectionItem()
    
    func addNewReadLinkItem()
}

// MARK: - ReadCollectionScene

public protocol ReadCollectionScene: Scenable {
    
    var interactor: ReadCollectionItemsSceneInteractable? { get }
}


// MARK: - AddReadLinkScene Input & Output

public protocol AddReadLinkSceneInput { }

public protocol AddReadLinkSceneOutput { }


// MARK: - AddReadLinkScene

public protocol AddReadLinkScene: Scenable {
    
    var input: AddReadLinkSceneInput? { get }

    var output: AddReadLinkSceneOutput? { get }
}


// MARK: - SelectAddItemTypeScene Input & Output

public protocol SelectAddItemTypeSceneInput { }

public protocol SelectAddItemTypeSceneOutput { }


// MARK: - SelectAddItemTypeScene

public protocol SelectAddItemTypeScene: Scenable, PangestureDismissableScene {
    
    var input: SelectAddItemTypeSceneInput? { get }

    var output: SelectAddItemTypeSceneOutput? { get }
}

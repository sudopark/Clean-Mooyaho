//
//  Scenes+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import UIKit

import Domain


// MARK: - AddItemNavigationScene Input & Output

public protocol AddItemNavigationSceneInput { }

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

// MARK: - EditLinkItemScene Input & Output

public protocol EditLinkItemSceneInput { }

public protocol EditLinkItemSceneOutput { }


// MARK: - EditLinkItemScene

public protocol EditLinkItemScene: Scenable {
    
    var input: EditLinkItemSceneInput? { get }

    var output: EditLinkItemSceneOutput? { get }
}

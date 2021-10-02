//
//  Scenes+AddItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import Foundation

import Domain


// MARK: - AddItemNavigationScene Input & Output

public protocol AddItemNavigationSceneInput { }

public protocol AddItemNavigationSceneOutput { }


// MARK: - AddItemNavigationScene

public protocol AddItemNavigationScene: Scenable {
    
    var input: AddItemNavigationSceneInput? { get }

    var output: AddItemNavigationSceneOutput? { get }
}

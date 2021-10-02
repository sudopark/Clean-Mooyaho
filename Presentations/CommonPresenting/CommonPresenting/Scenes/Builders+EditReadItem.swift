//
//  Builders+EditReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/02.
//

import Foundation

import Domain


// MARK: - Builder + DependencyInjector Extension

public protocol SelectAddItemTypeSceneBuilable {
    
    func makeSelectAddItemTypeScene(_ completed: @escaping (Bool) -> Void) -> SelectAddItemTypeScene
}


// MARK: - AddItemNavigationSceneBuilable

public protocol AddItemNavigationSceneBuilable {
    
    func makeAddItemNavigationScene(at collectionID: String?,
                                    _ completed: @escaping (ReadLink) -> Void) -> AddItemNavigationScene
}

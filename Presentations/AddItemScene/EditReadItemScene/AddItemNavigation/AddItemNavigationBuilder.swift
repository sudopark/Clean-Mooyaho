//
//  
//  AddItemNavigationBuilder.swift
//  AddItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol AddItemNavigationSceneBuilable {
    
    func makeAddItemNavigationScene(at collectionID: String?,
                                    _ completed: @escaping (ReadLink) -> Void) -> AddItemNavigationScene
}

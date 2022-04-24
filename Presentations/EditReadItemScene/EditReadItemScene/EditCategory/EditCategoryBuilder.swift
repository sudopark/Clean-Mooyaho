//
//  
//  EditCategoryBuilder.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/08.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol EditCategorySceneBuilable {
    
    func makeEditCategoryScene(startWith select: [ItemCategory],
                               listener: EditCategorySceneListenable?) -> EditCategoryScene
}

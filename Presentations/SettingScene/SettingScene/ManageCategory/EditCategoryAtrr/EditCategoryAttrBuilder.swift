//
//  
//  EditCategoryAttrBuilder.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/04.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol EditCategoryAttrSceneBuilable {
    
    func makeEditCategoryAttrScene(category: ItemCategory,
                                   listener: EditCategoryAttrSceneListenable?) -> EditCategoryAttrScene
}


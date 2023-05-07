//
//  
//  EditCategoryAttrRouter.swift
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


// MARK: - Routing

public protocol EditCategoryAttrRouting: Routing, Sendable {
    
    func selectNewColor(_ stratWith: String)
    
    func alertNameDuplicated(_ name: String)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditCategoryAttrRouterBuildables = ColorSelectSceneBuilable

public final class EditCategoryAttrRouter: Router<EditCategoryAttrRouterBuildables>, EditCategoryAttrRouting { }


extension EditCategoryAttrRouter {
    
    // EditCategoryAttrRouting implements
    private var currentInteractor: EditCategoryAttrSceneInteractable? {
        return (self.currentScene as? EditCategoryAttrScene)?.interactor
    }
    
    public func selectNewColor(_ stratWith: String) {
        
        Task { @MainActor in
            let dependency = SelectColorDepedency(startWithSelect: stratWith,
                                                  colorSources: ItemCategory.colorCodes)
            guard let next = self.nextScenesBuilder?
                    .makeColorSelectScene(dependency, listener: self.currentInteractor)
            else {
                return
            }
            
            self.currentScene?.present(next, animated: true, completion: nil)
        }
    }
    
    public func alertNameDuplicated(_ name: String) {
        self.showToast("A category with the same name already exists.".localized)
    }
}

//
//  
//  EnterHoorayTagRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/07.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EnterHoorayTagRouting: Routing {
    
    func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?)
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EnterHoorayTagRouterBuildables = MakeHooraySceneBuilable

public final class EnterHoorayTagRouter: Router<EnterHoorayTagRouterBuildables>, EnterHoorayTagRouting { }


extension EnterHoorayTagRouter {
    
    public func presentNextInputStage(_ form: NewHoorayForm, selectedImage: String?) {
        
        guard let presenting = self.currentScene?.presentingViewController,
              let next = self.nextScenesBuilder?.makeSelectHoorayPlaceScene(form: form,
                                                                            previousSelectImagePath: selectedImage) else {
            return
        }
        
        self.currentScene?.dismiss(animated: true) { [weak presenting] in
            presenting?.present(next, animated: true, completion: nil)
        }
    }
}

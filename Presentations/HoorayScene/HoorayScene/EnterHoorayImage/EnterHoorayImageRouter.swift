//
//  
//  EnterHoorayImageRouter.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/06.
//
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Routing

public protocol EnterHoorayImageRouting: Routing {
    
    func askImagePickingModel(_ form: ActionSheetForm)
    
    func presentEditScene(selectImage image: UIImage, edited: (UIImage) -> Void)
    
    func presentImagePicker(isCamera: Bool) -> ImagePickerScenePresenter?
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EnterHoorayImageRouterBuildables = ImagePickerSceneBuilable

public final class EnterHoorayImageRouter: Router<EnterHoorayImageRouterBuildables>, EnterHoorayImageRouting { }


extension EnterHoorayImageRouter {
    
    public func askImagePickingModel(_ form: ActionSheetForm) {
        self.alertActionSheet(form)
    }
    
    public func presentEditScene(selectImage image: UIImage, edited: (UIImage) -> Void) {
        logger.todoImplement()
    }
    
    public func presentImagePicker(isCamera: Bool) -> ImagePickerScenePresenter? {
        
        guard let next = self.nextScenesBuilder?.makeImagePickerScene(isCamera: isCamera) else { return nil }
        
        return next.presenter
    }
}

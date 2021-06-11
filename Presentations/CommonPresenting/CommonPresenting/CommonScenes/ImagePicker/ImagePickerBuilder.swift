//
//  
//  ImagePickerBuilder.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/07.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol ImagePickerSceneBuilable {
    
    func makeImagePickerScene(isCamera: Bool) -> ImagePickerScene
}

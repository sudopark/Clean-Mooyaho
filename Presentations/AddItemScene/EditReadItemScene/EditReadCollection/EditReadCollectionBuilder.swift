//
//  
//  EditReadCollectionBuilder.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/03.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol EditReadCollectionSceneBuilable {
    
    func makeEditReadCollectionScene() -> EditReadCollectionScene
}

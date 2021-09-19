//
//  
//  ReadCollectionBuilder.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/19.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol ReadCollectionSceneBuilable {
    
    func makeReadCollectionScene() -> ReadCollectionScene
}

//
//  
//  ReadCollectionMainBuilder.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting

// MARK: - Builder + DependencyInjector Extension

public protocol ReadCollectionMainSceneBuilable {
    
    func makeReadCollectionMainScene(navigationListener: ReadCollectionNavigateListenable?) -> ReadCollectionMainScene
}

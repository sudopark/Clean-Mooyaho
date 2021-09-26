//
//  
//  AddReadLinkBuilder.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/26.
//
//  ReadItemScene
//
//  Created sudo.park on 2021/09/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting

// MARK: - Builder + DependencyInjector Extension

public protocol AddReadLinkSceneBuilable {
    
    func makeAddReadLinkScene(collectionID: String?,
                              itemAddded: (() -> Void)?) -> AddReadLinkScene
}

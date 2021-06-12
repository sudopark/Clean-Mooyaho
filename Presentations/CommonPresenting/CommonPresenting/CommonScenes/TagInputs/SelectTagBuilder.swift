//
//  
//  SelectTagBuilder.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/12.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import Domain


// MARK: - Builder + DI Container Extension

public protocol SelectTagSceneBuilable {
    
    func makeSelectTagScene(startWith tags: [Tag], total: [Tag]) -> SelectTagScene
}

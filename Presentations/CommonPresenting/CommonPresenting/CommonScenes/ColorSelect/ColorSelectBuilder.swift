//
//  
//  ColorSelectBuilder.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/11.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/10/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit


// MARK: - Builder + DependencyInjector Extension

public struct SelectColorDepedency {
    
    public let startWithSelect: String?
    public let colorSources: [String]
    
    public init(startWithSelect: String?, colorSources: [String]) {
        self.startWithSelect = startWithSelect
        self.colorSources = colorSources
    }
}

@MainActor
public protocol ColorSelectSceneBuilable {
    
    func makeColorSelectScene(_ dependency: SelectColorDepedency,
                              listener: ColorSelectSceneListenable?) -> ColorSelectScene
}

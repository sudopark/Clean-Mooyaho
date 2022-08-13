//
//  
//  TextInputBuilder.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/12.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit


// MARK: - Builder + DI Container Extension

@MainActor
public protocol TextInputSceneBuilable {
    
    func makeTextInputScene(_ inputMode: TextInputMode,
                            listener: TextInputSceneListenable?) -> TextInputScene
}

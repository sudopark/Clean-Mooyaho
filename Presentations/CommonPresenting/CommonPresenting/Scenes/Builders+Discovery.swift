//
//  Builders+Discovery.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/14.
//

import UIKit


// MARK: - Builder + DependencyInjector Extension

public protocol DiscoveryMainSceneBuilable {
    
    func makeDiscoveryMainScene(listener: DiscoveryMainSceneListenable?) -> DiscoveryMainScene
}

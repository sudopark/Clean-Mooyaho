//
//  
//  SharedMemberListBuilder.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2022/01/01.
//
//  DiscoveryScene
//
//  Created sudo.park on 2022/01/01.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol SharedMemberListSceneBuilable {
    
    func makeSharedMemberListScene(
        sharedCollection: SharedReadCollection,
        memberIDs: [String],
        listener: SharedMemberListSceneListenable?
    ) -> SharedMemberListScene
}

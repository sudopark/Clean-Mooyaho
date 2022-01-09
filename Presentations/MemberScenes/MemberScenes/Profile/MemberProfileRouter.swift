//
//  
//  MemberProfileRouter.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/12/11.
//
//  MemberScenes
//
//  Created sudo.park on 2021/12/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol MemberProfileRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias MemberProfileRouterBuildables = EmptyBuilder

public final class MemberProfileRouter: Router<MemberProfileRouterBuildables>, MemberProfileRouting { }


extension MemberProfileRouter {
    
    // MemberProfileRouting implements
    private var currentInteractor: MemberProfileSceneInteractable? {
        return (self.currentScene as? MemberProfileScene)?.interactor
    }
}

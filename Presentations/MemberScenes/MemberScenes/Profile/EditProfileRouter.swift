//
//  
//  EditProfileRouter.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/30.
//
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol EditProfileRouting: Routing { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias EditProfileRouterBuildables = EmptyBuilder

public final class EditProfileRouter: Router<EditProfileRouterBuildables>, EditProfileRouting { }


extension EditProfileRouter {
    
    // EditProfileRouting implements
}

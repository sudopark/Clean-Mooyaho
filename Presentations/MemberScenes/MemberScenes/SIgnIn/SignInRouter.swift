//
//  
//  SignInRouter.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/29.
//
//  MemberScenes
//
//  Created sudo.park on 2021/05/29.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SignInRouting: Routing, Sendable { }

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SignInRouterBuildables = EmptyBuilder

public final class SignInRouter: Router<SignInRouterBuildables>, SignInRouting { }


extension SignInRouter { }

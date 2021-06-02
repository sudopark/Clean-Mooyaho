//
//  
//  SignInBuilder.swift
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


// MARK: - Builder + DI Container Extension

public enum SignInSceneEvents {
    case signInSuccess
}

public protocol SignInSceneBuilable {
    
    func makeSignInScene(_ listener: @escaping Listener<SignInSceneEvents>) -> SignInScene
}

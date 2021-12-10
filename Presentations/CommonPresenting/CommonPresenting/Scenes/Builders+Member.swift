//
//  Builders+Member.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/12/11.
//

import Foundation

import Domain


public protocol SignInSceneBuilable {
    
    func makeSignInScene(_ listener: SignInSceneListenable?) -> SignInScene
}

public protocol EditProfileSceneBuilable {
    
    func makeEditProfileScene() -> EditProfileScene
}

public protocol MemberProfileSceneBuilable {
    
    func makeMemberProfileScene(memberID: String,
                                listener: MemberProfileSceneListenable?) -> MemberProfileScene
}


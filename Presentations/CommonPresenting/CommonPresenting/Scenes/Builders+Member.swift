//
//  Builders+Member.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/12/11.
//

import Foundation

import Domain


@MainActor
public protocol SignInSceneBuilable {
    
    func makeSignInScene(_ listener: SignInSceneListenable?) -> SignInScene
}

@MainActor
public protocol EditProfileSceneBuilable {
    
    func makeEditProfileScene() -> EditProfileScene
}

@MainActor
public protocol MemberProfileSceneBuilable {
    
    func makeMemberProfileScene(memberID: String,
                                listener: MemberProfileSceneListenable?) -> MemberProfileScene
}

@MainActor
public protocol RecoverAccountSceneBuilable {
    
    func makeRecoverAccountScene(listener: RecoverAccountSceneListenable?) -> RecoverAccountScene
}

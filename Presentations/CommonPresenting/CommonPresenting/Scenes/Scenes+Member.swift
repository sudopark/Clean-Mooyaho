//
//  Scenes+Member.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation


import RxSwift

import Domain


// MARK: - SignInScene

public protocol SignInSceneInteractable: Sendable { }

public protocol SignInSceneListenable: Sendable, AnyObject {
    
    func signIn(didCompleted member: Member)
}

public protocol SignInScene: Scenable, PangestureDismissableScene {
    
    nonisolated var interactor: SignInSceneInteractable? { get }
}


// MARK: - EditProfileScene

public protocol EditProfileSceneInteractable: Sendable, ImagePickerSceneListenable, SelectEmojiSceneListenable { }

public protocol EditProfileScene: Scenable {
    
    nonisolated var interactor: EditProfileSceneInteractable? { get }
}


// MARK: - MemberProfileScene Interactable & Listenable

public protocol MemberProfileSceneInteractable: Sendable { }

public protocol MemberProfileSceneListenable: Sendable, AnyObject { }


// MARK: - MemberProfileScene

public protocol MemberProfileScene: Scenable {
    
    nonisolated var interactor: MemberProfileSceneInteractable? { get }
}


// MARK: - RecoverAccountScene Interactable & Listenable

public protocol RecoverAccountSceneInteractable: Sendable { }

public protocol RecoverAccountSceneListenable: Sendable, AnyObject {
    
    func recoverAccount(didCompleted recoveredMember: Member)
}


// MARK: - RecoverAccountScene

public protocol RecoverAccountScene: Scenable {

   nonisolated var interactor: RecoverAccountSceneInteractable? { get }
}

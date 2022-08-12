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

@MainActor
public protocol SignInSceneInteractable { }

@MainActor
public protocol SignInSceneListenable: AnyObject {
    
    func signIn(didCompleted member: Member)
}

@MainActor
public protocol SignInScene: Scenable, PangestureDismissableScene {
    
    var interactor: SignInSceneInteractable? { get }
}


// MARK: - EditProfileScene

@MainActor
public protocol EditProfileSceneInteractable: ImagePickerSceneListenable, SelectEmojiSceneListenable { }

@MainActor
public protocol EditProfileScene: Scenable {
    
    var interactor: EditProfileSceneInteractable? { get }
}


// MARK: - MemberProfileScene Interactable & Listenable

@MainActor
public protocol MemberProfileSceneInteractable { }

@MainActor
public protocol MemberProfileSceneListenable: AnyObject { }


// MARK: - MemberProfileScene

@MainActor
public protocol MemberProfileScene: Scenable {
    
    var interactor: MemberProfileSceneInteractable? { get }
}


// MARK: - RecoverAccountScene Interactable & Listenable

@MainActor
public protocol RecoverAccountSceneInteractable { }

@MainActor
public protocol RecoverAccountSceneListenable: AnyObject {
    
    func recoverAccount(didCompleted recoveredMember: Member)
}


// MARK: - RecoverAccountScene

@MainActor
public protocol RecoverAccountScene: Scenable {
    
    var interactor: RecoverAccountSceneInteractable? { get }
}

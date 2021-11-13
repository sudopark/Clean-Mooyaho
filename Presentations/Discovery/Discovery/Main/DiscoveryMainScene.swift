//
//  DiscoveryMainScene.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/14.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - DiscoveryMainViewModelImple conform DiscoveryMainSceneInteractor

extension DiscoveryMainViewModelImple: DiscoveryMainSceneInteractable {

}


// MARK: - DiscoveryMainViewController provide DiscoveryMainSceneInteractor

extension DiscoveryMainViewController {

    public var interactor: DiscoveryMainSceneInteractable? {
        return self.viewModel as? DiscoveryMainSceneInteractable
    }
}

//
//  CollectionInverseNavigationCoordinating.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/20.
//

import UIKit

import Domain


public protocol CollectionInverseNavigationCoordinating: AnyObject {
    
    func inverseNavigating(prepareParent collectionID: String)
}

public final class CollectionInverseNavigationCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let makeParent: (String) -> UIViewController?
    
    public init(navigationController: UINavigationController?,
                makeParent: @escaping (String) -> UIViewController?) {
        self.navigationController = navigationController
        self.makeParent = makeParent
    }
}

extension CollectionInverseNavigationCoordinator: CollectionInverseNavigationCoordinating {
    
    public func inverseNavigating(prepareParent collectionID: String) {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1,
              let parentController = self.makeParent(collectionID)
        else {
            return
        }
        
        logger.print(level: .debug, "inverse navigating prepare parent: \(collectionID)")        
        let lastIndex = navigationController.viewControllers.count
        var newControllers = navigationController.viewControllers + [parentController]
        newControllers.swapAt(lastIndex, lastIndex-1)
        self.navigationController?.viewControllers = newControllers
    }
}

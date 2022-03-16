//
//  CollectionInverseNavigationCoordinating.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/20.
//

import UIKit

import Domain


public protocol CollectionInverseParentMakeParameter { }

extension String: CollectionInverseParentMakeParameter { }
extension ReadCollection: CollectionInverseParentMakeParameter { }


public protocol CollectionInverseNavigationCoordinating: AnyObject {
    
    func inverseNavigating(prepareParent parameter: CollectionInverseParentMakeParameter)
}

public final class CollectionInverseNavigationCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let makeParent: (CollectionInverseParentMakeParameter) -> UIViewController?
    
    public init(navigationController: UINavigationController?,
                makeParent: @escaping (CollectionInverseParentMakeParameter) -> UIViewController?) {
        self.navigationController = navigationController
        self.makeParent = makeParent
    }
}

extension CollectionInverseNavigationCoordinator: CollectionInverseNavigationCoordinating {
    
    public func inverseNavigating(prepareParent parameter: CollectionInverseParentMakeParameter) {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1,
              let parentController = self.makeParent(parameter)
        else {
            return
        }
        
        logger.print(level: .debug, "inverse navigating prepare parent: \(parameter)")
        let lastIndex = navigationController.viewControllers.count
        var newControllers = navigationController.viewControllers + [parentController]
        newControllers.swapAt(lastIndex, lastIndex-1)
        self.navigationController?.viewControllers = newControllers
    }
}

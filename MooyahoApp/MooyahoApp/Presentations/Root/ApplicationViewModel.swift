//
//  ApplicationViewModel.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


public final class ApplicationViewModel {
    
    
    private let router: ApplicationRootRouting
    
    public init(router: ApplicationRootRouting) {
        self.router = router
    }
    
}

// Interactor

extension ApplicationViewModel {
    
    func appDidLaunched() {
        
        // TODO: route to main
        self.router.routeMain()
    }
}

// Prenseter

extension ApplicationViewModel {
    
}

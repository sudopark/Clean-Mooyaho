//
//  Expression+Extensions.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


extension Bool {
    
    public func then(_ action: () -> Void) {
        guard self else { return }
        action()
    }
}

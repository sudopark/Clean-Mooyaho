//
//  Presentable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


@MainActor
public protocol Presenting {
    
    func setupLayout()
    
    func setupStyling()
}

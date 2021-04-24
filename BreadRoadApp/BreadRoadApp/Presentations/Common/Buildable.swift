//
//  Builder.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol Buildable { }


public protocol EmptyBuilder: Buildable { }


extension DIContainers: EmptyBuilder { }

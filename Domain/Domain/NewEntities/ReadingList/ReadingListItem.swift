//
//  ReadingListItem.swift
//  Domain
//
//  Created by sudo.park on 2022/08/23.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - ReadingListItem

public protocol ReadingListItem: Sendable  {
    
    var uuid: String { get }
    var parentID: String? { get set }
}

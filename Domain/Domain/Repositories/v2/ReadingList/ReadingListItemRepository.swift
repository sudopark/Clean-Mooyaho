//
//  ReadingListItemRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/08/17.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift

public protocol ReadingListItemRepository: Sendable {
    
    func loadItems(in ids: [String]) -> Observable<[ReadingListItem]>
}

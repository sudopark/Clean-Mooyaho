//
//  StubClipboardService.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/31.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain


class StubClipBoardService: ClipboardServie {
    
    var copiedString: String?
    
    func getCopedString() -> String? {
        return self.copiedString
    }
}

//
//  ClipboardService.swift
//  Domain
//
//  Created by sudo.park on 2021/10/31.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit


public protocol ClipboardServie: Sendable {
    
    func getCopedString() -> String?
    
    func copy(_ string: String)
}


extension UIPasteboard: ClipboardServie {
    
    public func getCopedString() -> String? {
        let sender = self.string
        return sender
    }
    
    public func copy(_ string: String) {
        self.string = string
    }
}

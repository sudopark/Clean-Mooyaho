//
//  View+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/11/11.
//

import SwiftUI


extension View {
    
    public func eventHandler<Handler>(
        _ keyPath: WritableKeyPath<Self, Handler>,
        _ handler: Handler
    ) -> Self {
        var sender = self
        sender[keyPath: keyPath] = handler
        return sender
    }
}

//
//  SwiftUI+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/09.
//

import SwiftUI



public extension View {
    
    func asAny() -> AnyView {
        return AnyView(self)
    }
}

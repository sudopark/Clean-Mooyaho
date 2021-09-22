//
//  SwiftUI+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/22.
//

import Foundation

import SwiftUI


extension View {
    
    public func asAnyView() -> AnyView {
        return AnyView(self)
    }
}

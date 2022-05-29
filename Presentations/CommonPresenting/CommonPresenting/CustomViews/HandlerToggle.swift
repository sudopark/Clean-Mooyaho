//
//  HandlerToggle.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/05/29.
//

import SwiftUI


extension Views {
    
    public struct HandlerToggle: View {
        
        @State private var isOn: Bool = false
        private let handler: (Bool) -> Void
        
        public init(initialState: Bool,
             _ handler: @escaping (Bool) -> Void) {
            self.isOn = initialState
            self.handler = handler
        }
        
        public var body: some View {
            Toggle(isOn: $isOn) { }
                .onChange(of: isOn, perform: handler)
        }
    }

}

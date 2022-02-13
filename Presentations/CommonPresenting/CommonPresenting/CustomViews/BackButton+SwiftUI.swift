//
//  BackButton+SwiftUI.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/13.
//

import SwiftUI

public struct BackButton: View {
    
    private let onTap: () -> Void
    public init(_ onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }
}

struct BackButton_SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        BackButton { }
    }
}

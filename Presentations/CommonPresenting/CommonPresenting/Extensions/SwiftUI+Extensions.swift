//
//  SwiftUI+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/09.
//

import SwiftUI


// MARK: - extension for casting

public extension View {
    
    func asAny() -> AnyView {
        return AnyView(self)
    }
}


// MARK: - extension for shape

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: self.corners,
            cornerRadii: .init(width: self.radius, height: self.radius)
        )
        return Path(path.cgPath)
    }
}

public extension View {
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }
}

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
    
    func endEditing() {
        Task {
            await MainActor.run {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                )
            }
        }
    }
}


public extension Spacer {
    
    func backgroundSpaceTapGesture(_ tapped: @escaping () -> Void) -> some View {
        ZStack {
            Color.black.opacity(0.001).onTapGesture(perform: tapped)
            Spacer()
        }
    }
}

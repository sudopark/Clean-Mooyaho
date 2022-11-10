//
//  ProgressLineView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/11/11.
//

import SwiftUI


public struct ProgressLine: Shape {
    
    public init() {}
    
    public func path(in rect: CGRect) -> Path {
        let start = CGPoint.zero
        let end = CGPoint(x: rect.width, y: rect.height)
        
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}


public struct ProgressLineView: View {
    
    @Binding private var progress: CGFloat
    public init(_ progress: Binding<CGFloat>) {
        self._progress = progress
    }
    
    public var body: some View {
        GeometryReader { geo in
            ProgressLine()
                .background(theme.colors.buttonBlue.asColor)
                .frame(width: geo.size.width * progress)
        }
    }
}


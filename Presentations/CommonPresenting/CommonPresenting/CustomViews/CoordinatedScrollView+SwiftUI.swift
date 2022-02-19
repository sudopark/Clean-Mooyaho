//
//  CoordinatedScrollView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/02/19.
//

import UIKit
import SwiftUI
import Prelude
import Optics

extension CGSize {
    
    func append(_ next: CGSize) -> CGSize {
        return self
            |> \.width +~ next.width
            |> \.height +~ next.height
    }
}

public struct ViewGeometry: Equatable {
    
    public var contentSize: CGSize = .zero
    public var size: CGSize = .zero
    public var offset: CGFloat = 0
    
    func append(_ geometry: ViewGeometry) -> ViewGeometry {
        return self
        |> \.contentSize %~ { $0.append(geometry.contentSize) }
        |> \.size %~ { $0.append(geometry.size) }
        |> \.offset +~ geometry.offset
    }
}

public struct ViewGeometryKey: PreferenceKey {
    
    public typealias Value = ViewGeometry
    public static var defaultValue: ViewGeometry = .init()
    
    public static func reduce(value: inout ViewGeometry, nextValue: () -> ViewGeometry) {
        value = value.append(nextValue())
    }
}

// MARK: - CoordinatedScrollView

public struct CoordinatedScrollView<Content: View>: View {
    
    private let content: Content
    private let coordinateSpaceName = UUID().uuidString
    
    public var onGeometryChanged: ((ViewGeometry) -> Void)?
    public var onScrollToBottomChanged: ((CGFloat) -> Void)?
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public init(_ content: Content) {
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                self.content
                .background(self.geometricReader(proxy))
                
            }
            .coordinateSpace(name: self.coordinateSpaceName)
            .onPreferenceChange(ViewGeometryKey.self) { geo in
                self.onGeometryChanged?(geo)
            }
        }
    }
    
    private func geometricReader(_ outsizeProxy: GeometryProxy) -> some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .named(self.coordinateSpaceName))
            let geometry = ViewGeometry(
                contentSize: frame.size,
                size: outsizeProxy.frame(in: .global).size,
                offset: -frame.minY
            )
            Color.clear
                .preference(key: ViewGeometryKey.self, value: geometry)
        }
    }
}


extension CoordinatedScrollView {
    
    public func onGeometryChanged(_ didChanged: @escaping (ViewGeometry) -> Void) -> CoordinatedScrollView {
        return self
        |> \.onGeometryChanged .~ pure(didChanged)
    }
}

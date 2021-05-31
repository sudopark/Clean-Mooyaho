//
//  BasePreview.swift
//  PreviewUIView
//
//  Created by sudo.park on 2021/05/31.
//

import SwiftUI

import MemberScenes

protocol PreviewSupportView: UIView {
    
    static func make() -> Self
}

struct WrapUIView<V: PreviewSupportView>: UIViewRepresentable {
    
    typealias UIViewType = V
    
    func makeUIView(context: Context) -> V {
        return V.make()
    }
    
    func updateUIView(_ uiView: V, context: Context) {
        
    }
}



extension EditProfileView : PreviewSupportView{
    
    static func make() -> EditProfileView {
        let view = EditProfileView()
        view.setupLayout()
        view.setupStyling()
        return view
    }
}

final class EmptyView: UIView, PreviewSupportView {
    static func make() -> EmptyView {
        return EmptyView()
    }
}

typealias TargerView = EditProfileView

class BasePreview: PreviewProvider {
    
    typealias Previews = WrapUIView<TargerView>
    
    static var previews: WrapUIView<TargerView> {
        return WrapUIView()
    }
}

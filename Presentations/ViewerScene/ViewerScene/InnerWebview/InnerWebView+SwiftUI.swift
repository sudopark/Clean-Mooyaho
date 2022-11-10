//
//  InnerWebView+SwiftUI.swift
//  ViewerScene
//
//  Created by sudo.park on 2022/11/10.
//

import SwiftUI
import UIKit

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


struct InnerWebView_SwiftUI: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}


private struct InnertWebViewToolbarInfoSection: View {
    
    let title: String
    @Binding var isEditable: Bool
    @Binding var progress: CGFloat
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var editHandler: (() -> Void)?
    var refreshHandler: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                
                if self.isEditable {
                    self.editButton
                }
                
                Spacer()
                Text(self.title)
                    .lineLimit(1)
                    .foregroundColor(self.theme.colors.text.withAlphaComponent(0.8).asColor)
                    .font(self.theme.fonts.get(12, weight: .regular).asFont)
                    .onTapGesture {
                        self.editHandler?()
                    }
                Spacer()
                
                self.refreshButton
            }
            .padding([.horizontal], 16)
            .padding([.vertical], 7)
            
            ProgressLineView($progress)
                .padding(.horizontal, 16)
                .frame(width: .infinity, height: 2)
        }
        .background(Views.RoundShadowView(cornerRadidus: 18))
    }
    
    private var editButton: some View {
        Button {
            self.editHandler?()
        } label: {
            Image(systemName: "square.and.pencil")
                .foregroundColor(self.theme.colors.secondaryTitle.asColor)
        }
        .frame(width: 22, height: 22)
    }
    
    private var refreshButton: some View {
        Button {
            self.refreshHandler?()
        } label: {
            Image(systemName: "arrow.clockwise.circle.fill")
                .foregroundColor(self.theme.colors.secondaryTitle.asColor)
        }
        .frame(width: 22, height: 22)
    }
    
    private var roundShadow: some View {
        
        let shadowColorAlpha: CGFloat = self.colorScheme == .light ? 0.4 : 0.1
        let shadowColor = UIColor.label.withAlphaComponent(shadowColorAlpha)
        return RoundedRectangle(cornerRadius: 18)
            .fill(self.theme.colors.appBackground.asColor)
            .shadow(color: shadowColor.asColor, radius: 0.1, y: 0.1)
    }
}

struct InnerWebView_SwiftUI_Previews: PreviewProvider {
    
    static var previews: some View {
        InnertWebViewToolbarInfoSection(
            title: "Title",
            isEditable: .constant(true),
            progress: .constant(0.5)
        )
        .eventHandler(\.editHandler) {
            print("edit called")
        }
        .eventHandler(\.refreshHandler) {
            print("refresh called")
        }
    }
}

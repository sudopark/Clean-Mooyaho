//
//  TopPullView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/12/19.
//

import UIKit


// MARK: - PullGuideView

public final class PullGuideView: BaseUIView, Presenting {
 
    let lineView = UIView()
    
    public func setupLayout() {
        
        self.addSubview(lineView)
        lineView.autoLayout.active(with: self) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.heightAnchor.constraint(equalToConstant: 6)
            $0.widthAnchor.constraint(equalToConstant: 50)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 9)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -9)
        }
    }
    
    public func setupStyling() {
     
        self.lineView.layer.cornerRadius = 3
        self.lineView.clipsToBounds = true
        self.lineView.backgroundColor = UIColor.lightGray
    }
}


// MARK: - SwiftUI PullGuideView

import SwiftUI

extension Views {
    
    public struct PullGuideView: View {
        
        public init() { }
        
        public var body: some View {
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 50, height: 6, alignment: .center)
                    .cornerRadius(3)
                    .background(self.uiContext.colors.raw.lightGray.asColor)
                Spacer()
            }
            .padding([.vertical], 9)
        }
    }
}

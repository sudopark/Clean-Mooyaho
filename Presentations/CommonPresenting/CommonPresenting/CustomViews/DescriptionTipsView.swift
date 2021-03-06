//
//  DescriptionTipsView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import Prelude
import Optics


public final class DescriptionTipsView: BaseUIView {
    
    private let stackView = UIStackView()
    
    final class TipView: BaseUIView {
        let dotLabel = UILabel()
        let descriptionLabel = UILabel()
    }
    
    public func updateTipsSpacing(_ spacing: CGFloat) {
        self.stackView.spacing = spacing
    }
    
    public func setupDescriptions(_ descriptions: [String]) {
        descriptions.forEach { description in
            let tipView = TipView()
            tipView.descriptionLabel.text = description
            self.stackView.addArrangedSubview(tipView)
            tipView.setupLayout()
            tipView.setupStyling()
            tipView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }
    }
}

extension DescriptionTipsView: Presenting {
    
    public func setupLayout() {
        self.addSubview(stackView)
        stackView.autoLayout.fill(self)
        stackView.axis = .vertical
    }
    
    public func setupStyling() {
        self.backgroundColor = .clear
    }
}

extension DescriptionTipsView.TipView: Presenting {
    
    func setupLayout() {
        self.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        self.addSubview(dotLabel)
        dotLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -4)
            $0.centerYAnchor.constraint(equalTo: descriptionLabel.firstBaselineAnchor, constant: -2)
            $0.widthAnchor.constraint(equalToConstant: 6)
        }
        dotLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setupStyling() {
        
        _ = dotLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.numberOfLines .~ 1
            |> \.text .~ "???"
        
        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemDescription
            |> \.numberOfLines .~ 0
            |> \.textAlignment .~ .left
    }
}



// MARK: SwiftUI version - DescriptionTipsView + TipView

import SwiftUI

extension String: Identifiable {
    public var id: String { self }
}

extension Views {
    
    public struct TipView: View {
        
        private let description: String
        public init(_ description: String) {
            self.description = description
        }
        
        public var body: some View {
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("???").listItemDescription()
                Text(self.description)
                    .listItemDescription()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            .background(Color.clear)
        }
    }
    
    public struct DescriptionTipsView: View {

        private let descriptions: [String]
        private let spacing: CGFloat
        
        public init(_ descriptions: [String], spacing: CGFloat = 4) {
            self.descriptions = descriptions
            self.spacing = spacing
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: self.spacing) {
                ForEach(self.descriptions) {
                    Views.TipView($0)
                }
            }
            .background(Color.clear)
        }
    }
}

struct DescriptionTipsView_Preview: PreviewProvider {
    
    
    static var previews: some View {
        
        let descs: [String] = [
            "?????? ?????? ?????? ?????? ????????? ?????????????????????.",
            "??????????????? ???????????? ???????????? ????????? ????????? ??? ????????? ????????? ?????? ?????? ?????? ?????? ???????????????.",
            "?????? ?????? ?????? ????????????(60???) ???????????? ????????? ????????? ??? ????????????.",
            "??? ????????? ?????? ???????????? ???????????? ?????? ???????????? ???????????? ?????? ??? ?????? ????????? ??? ???????????? ?????????."
        ]
        Views.DescriptionTipsView(descs)
    }
}

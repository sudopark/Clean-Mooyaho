//
//  BaseTableViewHeaderView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/12/03.
//

import UIKit

import Prelude
import Optics


public final class BaseTableViewHeaderView: BaseUIView, Presenting {
    
    private let titleLabel = UILabel()
    
    public func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    public func setupLayout() {
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 13)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
    }
    
    public func setupStyling() {
        _ = self.titleLabel |> { self.uiContext.decorating.header($0) }
    }
}

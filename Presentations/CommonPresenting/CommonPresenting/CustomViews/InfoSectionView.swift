//
//  File.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/04.
//

import UIKit


public final class InfoSectionView<InnerView: UIView>: BaseUIView, Presenting {
    
    public let innerView = InnerView()
    public let arrowImageView = UIImageView()
    public let underLineView = UIView()
    
    public func setupLayout() {
        self.addSubview(arrowImageView)
        arrowImageView.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -10)
        }
        
        self.addSubview(innerView)
        innerView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -16-1)
            $0.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
        }
        (self.innerView as? Presenting)?.setupLayout()
        self.innerView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.addSubview(underLineView)
        underLineView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
    }
    
    public func setupStyling() {
        (self.innerView as? Presenting)?.setupStyling()
        
        self.arrowImageView.image = UIImage(named: "chevron.right")
        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.tintColor = .lightGray.withAlphaComponent(0.5)
        
        self.underLineView.backgroundColor = .groupTableViewBackground
    }
}

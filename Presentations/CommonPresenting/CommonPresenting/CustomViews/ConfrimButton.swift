//
//  ConfrimButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/06.
//

import UIKit


public class ConfirmButton: UIButton { }


extension ConfirmButton: Presenting {
    
    public func setupLayout() { }
    
    public func setupStyling() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = UIColor.systemBlue
        self.setTitle("Confirm", for: .normal)
        self.setTitleColor(.white, for: .normal)
    }
    
    public func setupLayout(_ parentView: UIView) {
        
        parentView.addSubview(self)
        self.autoLayout.active(with: parentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
    }
}

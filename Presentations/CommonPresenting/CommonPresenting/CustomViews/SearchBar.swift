//
//  SearchBar.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/09.
//

import UIKit


public final class SearchBar: BaseUIView {
    
    
    public let searchIconImageView = UIImageView()
    public let inputField = UITextField()
    public let activityIndicator = UIActivityIndicatorView()
    public let clearButton = UIButton(type: .system)
}

extension SearchBar: Presenting {
    
    
    public func setupLayout() {
        
        self.addSubview(self.searchIconImageView)
        searchIconImageView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor, multiplier: 0.75)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        
        self.addSubview(activityIndicator)
        activityIndicator.autoLayout.active(with: self.searchIconImageView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
        }
        
        self.addSubview(clearButton)
        clearButton.autoLayout.active(with: self) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor, multiplier: 0.65)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
        }
        
        self.addSubview(self.inputField)
        inputField.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -4)
            $0.topAnchor.constraint(equalTo: self.topAnchor, constant: 6)
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6)
        }
    }
    
    public func setupStyling() {
        
        self.searchIconImageView.image = UIImage(named: "magnifyingglass")
        
        self.clearButton.setImage(UIImage(named: "xmark.circle.fill"), for: .normal)
        self.clearButton.isHidden = true
        
        self.activityIndicator.hidesWhenStopped = true
    }
}


import RxSwift
import RxCocoa


extension Reactive where Base: SearchBar {
    
    public var text: Observable<String> {
        return self.base.inputField.rx.text.orEmpty
            .do(onNext: { [weak base] text in
                base?.clearButton.isHidden = text.isNotEmpty
            })
    }
    
    public var tapClear: ControlEvent<Void> {
        return self.base.clearButton.rx.tap
    }
    
    public var isSearching: Binder<Bool> {
        return self.base.activityIndicator.rx.isAnimating
    }
}

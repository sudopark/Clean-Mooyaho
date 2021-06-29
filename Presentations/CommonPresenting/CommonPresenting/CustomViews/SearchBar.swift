//
//  SearchBar.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/09.
//

import UIKit


public final class SearchBar: BaseUIView {
    
    public let searchIconImageView = UIImageView()
    public let inputBackgroundView = UIView()
    public let inputField = UITextField()
    public let activityIndicator = UIActivityIndicatorView()
    public let clearButton = UIButton(type: .system)
}

extension SearchBar: Presenting {
    
    
    public func setupLayout() {
        
        self.addSubview(inputBackgroundView)
        inputBackgroundView.autoLayout.fill(self, edges: .init(top: 6, left: 12, bottom: 6, right: 8))
        
        inputBackgroundView.addSubview(self.searchIconImageView)
        searchIconImageView.autoLayout.active(with: inputBackgroundView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 6)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.widthAnchor.constraint(equalToConstant: 15)
        }
        
        inputBackgroundView.addSubview(activityIndicator)
        activityIndicator.autoLayout.active(with: self.searchIconImageView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor)
        }
        
        inputBackgroundView.addSubview(clearButton)
        clearButton.autoLayout.active(with: inputBackgroundView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.widthAnchor.constraint(equalToConstant: 15)
        }
        
        inputBackgroundView.addSubview(self.inputField)
        inputField.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -4)
            $0.topAnchor.constraint(equalTo: inputBackgroundView.topAnchor, constant: 6)
            $0.bottomAnchor.constraint(equalTo: inputBackgroundView.bottomAnchor, constant: -6)
        }
    }
    
    public func setupStyling() {
        
        self.inputBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.inputBackgroundView.layer.cornerRadius = 4
        self.inputBackgroundView.clipsToBounds = true
        
        self.searchIconImageView.image = UIImage(named: "magnifyingglass")
        
        self.clearButton.setImage(UIImage(named: "xmark.circle.fill"), for: .normal)
        self.clearButton.isHidden = true
        self.clearButton.tintColor = .gray
        
        self.activityIndicator.hidesWhenStopped = true
    }
}


import RxSwift
import RxCocoa


extension Reactive where Base: SearchBar {
    
    public var text: Observable<String> {
        return self.base.inputField.rx.text.orEmpty
            .do(onNext: { [weak base] text in
                base?.clearButton.isHidden = text.isEmpty
            })
    }
    
    public var tapClear: ControlEvent<Void> {
        return self.base.clearButton.rx.tap
    }
    
    public var isSearching: Binder<Bool> {
        return self.base.activityIndicator.rx.isAnimating
    }
}

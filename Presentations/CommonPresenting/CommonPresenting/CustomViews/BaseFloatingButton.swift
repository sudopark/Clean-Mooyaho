//
//  BaseFloatingButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/05/28.
//

import UIKit

import RxSwift
import RxCocoa


open class BaseFloatingButton: BaseUIView, Presenting {

    public let roundView = RoundShadowView()
    public let titleLabel = UILabel()
    public let descriptionView = UILabel()
    fileprivate let closeImageView = UIImageView()
    fileprivate let backgroundButton = UIButton()
    
    public func showButtonWithAnimation() {
        
        self.roundView.updateLayer()
        
        self.isHidden = false
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 0.5, y: 1.0)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .overrideInheritedCurve, animations: { [weak self] in
            self?.alpha = 1.0
            self?.transform = .identity
        })
    }
    
    public func hideButonWithAniation() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .overrideInheritedCurve, animations: { [weak self] in
            self?.alpha = 0.0
            self?.transform = CGAffineTransform(scaleX: 0.1, y: 1.0)
        }, completion: { [weak self] _ in
            self?.isHidden = true
        })
    }
    
    public func setupLayout() {
        
        self.addSubview(roundView)
        roundView.autoLayout.fill(self)
        
        self.addSubview(closeImageView)
        closeImageView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        let containerView = UIView()
        self.addSubview(containerView)
        containerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -12)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: containerView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        
        containerView.addSubview(descriptionView)
        descriptionView.autoLayout.active(with: containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        }
        
        self.addSubview(backgroundButton)
        backgroundButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -12)
        }
    }
    
    open func setupStyling() {
        
        self.roundView.cornerRadius = 15
        self.roundView.fillColor = self.uiContext.colors.appSecondBackground
        self.roundView.shadowOpacity = 0.9
        
        self.closeImageView.image = UIImage(systemName: "xmark")
        self.closeImageView.tintColor = self.uiContext.colors.text
        self.closeImageView.contentMode = .scaleAspectFit
        
        self.titleLabel.font = self.uiContext.fonts.get(15, weight: .medium)
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.textAlignment = .center
        
        self.descriptionView.font = self.uiContext.fonts.get(12, weight: .regular)
        self.descriptionView.textColor = self.uiContext.colors.secondaryTitle
        self.descriptionView.textAlignment = .center
        self.descriptionView.numberOfLines = 1
    }
}


public extension Reactive where Base: BaseFloatingButton {
    
    func throttleTap() -> Observable<Void> {
        return base.backgroundButton.rx.tap.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
    }
    
    func closeTap() -> Observable<Void> {
        return base.closeImageView.rx.addTapgestureRecognizer()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in }
    }
}

//
//  ConfirmButton.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import UIKit


// MARK: - ConfirmButton

public final class ConfirmButton: BaseUIView {
    
    let button = UIButton(type: .system)
    public let loadingView = LoadingView()
    
    public var title: String? {
        didSet {
            self.button.setTitle(title, for: .normal)
        }
    }

    public var isEnabled: Bool = true {
        didSet {
            self.isUserInteractionEnabled = isEnabled
            self.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    public func updateIsLoading(_ isLoading: Bool) {
        if isLoading {
            self.button.isHidden = true
            self.loadingView.updateIsLoading(true)
        } else {
            self.loadingView.updateIsLoading(false)
            self.button.isHidden = false
        }
    }
}


extension ConfirmButton: Presenting {
    
    public func setupLayout(_ parentView: UIView) {
        
        parentView.addSubview(self)
        self.autoLayout.active(with: parentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        self.setupLayout()
    }
    
    public func setupLayout() {
        
        self.addSubview(button)
        button.autoLayout.fill(self)
        
        self.addSubview(loadingView)
        loadingView.autoLayout.fill(self)
        loadingView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = self.uiContext.colors.accentColor
        
        self.loadingView.setupStyling()
        self.button.setTitleColor(self.loadingView.layerColor, for: .normal)
        self.button.setTitle("Confirm".localized, for: .normal)
        self.button.titleLabel?.font = self.uiContext.fonts.get(16, weight: .medium)
    }
}


// MARK: - ConfirmButton Reactive Extension

import RxSwift
import RxCocoa

extension Reactive where Base: ConfirmButton {
    
    @MainActor
    public func throttleTap() -> Observable<Void> {
        
        let runFeedback: () -> Void = { [weak base] in
            base?.providerFeedbackImpact(with: .soft)
        }
        
        return base.button.rx.throttleTap()
            .do(onNext: runFeedback)
    }
    
    @MainActor
    public var isLoading: Binder<Bool> {
        Binder(base) { base, isLoading in
            base.updateIsLoading(isLoading)
        }
    }
}


// MARK: - SwiftUI ConfirmButton

import SwiftUI

extension Views {
    
    public struct ConfirmButton: View {
        
        @Binding var isLoading: Bool
        @Binding var isEnabled: Bool
        private let confirmed: () -> Void
        
        public init(isLoading: Binding<Bool> = .constant(false),
                    isEnabled: Binding<Bool> = .constant(true),
                    confirmed: @escaping () -> Void) {
            self._isLoading = isLoading
            self._isEnabled = isEnabled
            self.confirmed = confirmed
        }
        
        public var body: some View {
            Button(action: self.confirmed) {
                
                if self.isLoading {
                    HStack {
                        Spacer()
                        Views.LoadingView(.white)
                            .frame(width: 40, height: 40)
                        Spacer()
                    }
                } else {
                    Text("Confirm".localized)
                        .font(theme.fonts.get(16, weight: .medium).asFont)
                        .foregroundColor(
                            .white.opacity(isEnabled ? 1.0 : 0.7)
                        )
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
                }
            }
            .background(
                theme.colors.accentColor.asColor.opacity(isEnabled ? 1.0 : 0.7)
            )
            .cornerRadius(5)
            .disabled(!self.isEnabled)
        }
    }
}


struct ConfirmButtonPreview: PreviewProvider {
    
    static var previews: some View {
        Views.ConfirmButton(isLoading: .constant(false)) { }
    }
}

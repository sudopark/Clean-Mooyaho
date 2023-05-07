//
//  
//  WaitMigrationView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/03/13.
//
//


import UIKit
import SwiftUI

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - WaitMigrationViewController

@MainActor
public final class WaitMigrationViewStateObject: ObservableObject {
    
    @Published var migrationProcessAndResult: MigrationProcessAndResult?
    @Published var messages: (String, String) = (
        "Wait for data migration".localized,
        "Your locally stored data is being uploaded to cloud storage.\nPlease wait until the operation is completed.".localized
    )
    
    public func bind(_ viewModel: WaitMigrationViewModel) {
        
        guard self.didBind == false else { return }
        self.didBind = true
        
        // TODO: bind state
        viewModel.migrationProcessAndResult
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] result in
                self?.migrationProcessAndResult = result
            })
            .disposed(by: self.disposeBag)
        
        viewModel.message
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] pair in
                self?.messages = pair
            })
            .disposed(by: self.disposeBag)
        
        viewModel.startMigration()
    }
    
    private let disposeBag = DisposeBag()
    private var didBind = false
}


// MARK: - WaitMigrationView

public struct WaitMigrationView: View {
    
    private let viewModel: WaitMigrationViewModel
    @StateObject var states: WaitMigrationViewStateObject = .init()
    
    public init(viewModel: WaitMigrationViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {

        Views.BaseBottomSlideMenuView {
            self.contentViews(by: self.states.migrationProcessAndResult)
                .padding([.horizontal, .bottom], 20)
        }
        .onAppear {
            self.states.bind(self.viewModel)
        }
    }
    
    private func contentViews(by result: MigrationProcessAndResult?) -> some View {
        switch result {
        case .migrating:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "🚀", isNeedAnimation: true, withAnimation: true)
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 20)
                self.doLaterButton()
            }
            .asAny()
            
        case .fail:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "😓")
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 20)
                self.doLaterButton()
            }
            .asAny()
            
        case .finished:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "🎉")
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 40)
                self.confirmButton()
            }
            .asAny()
            
        case .finishWithNotStarted:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "👍")
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 40)
                self.confirmButton()
            }
            .asAny()
            
        default:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "🚀", isNeedAnimation: true)
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 20)
                self.doLaterButton()
            }
            .asAny()
        }
    }
     
    private func titleAreaView(_ title: String, icon: String,
                               isNeedAnimation: Bool = false,
                               withAnimation: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .smallHeader()
            Text(icon)
                .smallHeader()
                .rocketAnimationOrNot(
                    animate: withAnimation, isNeedAnimation: isNeedAnimation
                )
        }
    }

    private func messageLabel(_ text: String) -> some View {
        Text(text)
            .font(self.uiContext.fonts.get(15, weight: .medium).asFont)
            .multilineTextAlignment(.center)
            .foregroundColor(self.uiContext.colors.descriptionText.asColor)
            .lineLimit(nil)
    }
    
    private func doLaterButton() -> some View {
        HStack {
            Spacer()
            Button {
                viewModel.doMigrationLater()
            } label: {
                Text("Or do it latter >".localized)
                    .font(self.uiContext.fonts.get(13.5, weight: .medium).asFont)
                    .foregroundColor(self.uiContext.colors.buttonBlue.asColor)
            }
        }
    }
    
    private func confirmButton() -> some View {
        Views.ConfirmButton {
            self.viewModel.confirmMigrationFinished()
        }
    }
}


private extension View {
    
    private var foreverAnimation: Animation {
        return Animation.linear(duration: 0.1)
            .repeatForever(autoreverses: true)
    }

    func rocketAnimationOrNot(animate: Bool, isNeedAnimation: Bool) -> some View {
        guard isNeedAnimation else {
            return self.asAny()
        }
        
        return self
            .rotationEffect(.degrees(animate ? -27 : -15))
            .animation(foreverAnimation)
            .asAny()
    }
}

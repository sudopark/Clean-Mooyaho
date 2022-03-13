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
                self.titleAreaView(self.states.messages.0, icon: "🚀", withAnimation: true)
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
                self.titleAreaView(self.states.messages.0, icon: "🎉", withAnimation: false)
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 40)
                self.confirmButton()
            }
            .asAny()
            
        case .finishWithNotStarted:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "👍", withAnimation: false)
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 40)
                self.confirmButton()
            }
            .asAny()
            
        default:
            return VStack {
                Spacer().frame(height: 24)
                self.titleAreaView(self.states.messages.0, icon: "🚀", withAnimation: false)
                Spacer().frame(height: 16)
                self.messageLabel(self.states.messages.1)
                Spacer().frame(height: 20)
                self.doLaterButton()
            }
            .asAny()
        }
    }
    
    private var foreverAnimation: Animation {
        return Animation.linear(duration: 0.1)
            .repeatForever(autoreverses: true)
    }
    
    private func titleAreaView(_ title: String, icon: String, withAnimation: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .smallHeader()
            Text(icon)
                .smallHeader()
                .rotationEffect(.degrees(withAnimation ? -27 : -15))
                .animation(self.foreverAnimation)
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


// MARK: - preview + temp

struct WaitMigrationView_Preview: PreviewProvider {
    
    class ViewModel: WaitMigrationViewModel {
        
        struct DummyError: Error {}
        let state = BehaviorSubject<UserDataMigrationStatus?>(value: .migrating)
        
        func startMigration() {
        }
        
        func doMigrationLater() {
            self.state.onNext(.idle)
        }
        
        func confirmMigrationFinished() { }
        
        var message: Observable<(title: String, description: String)> {
            let transform: (UserDataMigrationStatus?) -> (String, String)?
            transform = { state in
                switch state {
                case .finished(let notStarted) where notStarted == false:
                    return (
                        "Migration complete".localized,
                        "All data uploads are complete!".localized
                    )
                    
                case .finished(let notStarted) where notStarted == true:
                    return (
                        "Migration finished".localized,
                        "All data has already been migrated.".localized
                    )
                case .fail:
                    return (
                        "Migration failed".localized,
                        "Migration failed. Please try again after a while.\n(You can restart the operation from the settings screen.)".localized
                    )
                default: return nil
                }
            }
            return self.state.compactMap { $0 }
                .compactMap(transform)
        }
        
        var migrationProcessAndResult: Observable<MigrationProcessAndResult> {
            return self.state
                .compactMap { $0 }
                .compactMap { .init($0) }
        }
        
        
    }
    
    static var previews: some View {
        let viewModel = ViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.startMigration()
        }
        return WaitMigrationView(viewModel: viewModel)
    }
}

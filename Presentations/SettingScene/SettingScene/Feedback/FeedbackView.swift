//
//  FeedbackView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/11/09.
//

import SwiftUI
import Combine

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


final class FeedbackViewStates: ObservableObject {
    
    @Published var isConfirmable: Bool = false
    @Published var isRegistering: Bool = false
    @Published var message: String = ""
    @Published var email: String = ""
    
    func bind(_ viewModel: FeedbackViewModel) {
        guard self.didBind == false else { return }
        self.didBind = true
        
        viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] flag in
                self?.isConfirmable = flag
            })
            .disposed(by: self.disposeBag)
        
        viewModel.isRegistering
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] flag in
                self?.isRegistering = flag
            })
            .disposed(by: self.disposeBag)
        
        $message
            .sink(receiveValue: { [weak viewModel] text in
                viewModel?.enterMessage(text)
            })
            .store(in: &self.cancellables)
        
        $email
            .sink(receiveValue: { [weak viewModel] text in
                viewModel?.enterContact(text)
            })
            .store(in: &self.cancellables)
    }
    
    private let disposeBag = DisposeBag()
    private var cancellables: Set<AnyCancellable> = []
    private var didBind = false
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
}


public struct FeedbackView: View {
    
    private let viewModel: FeedbackViewModel
    @StateObject private var state = FeedbackViewStates()
    
    public init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Views.BaseBottomSlideMenuView {
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Feedback".localized)
                    .smallHeader()
                    .padding(.top, 20)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $state.message)
                        .autocorrectionDisabled(true)
                    
                    if state.message.isNotEmpty == false {
                        Text("Enter a message".localized)
                            .placeHolder()
                            .padding(.top, 10)
                            .padding(.leading, 4)
                    }
                }
                .frame(height: 120)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email".localized)
                        .listSectionTitle()
                    
                    TextField("place holder", text: $state.email)
                        .font(self.theme.fonts.get(13, weight: .regular).asFont)
                }
                
                Views.ConfirmButton(
                    isLoading: $state.isRegistering,
                    isEnabled: $state.isConfirmable
                ) {
                    viewModel.register()
                }
                .padding(.top, 4)
            }
            .padding([.horizontal, .bottom], 20)
            .onAppear {
                self.state.bind(viewModel)
            }
            
        } outsideTap: {
            self.viewModel.close()
        }
    }
}

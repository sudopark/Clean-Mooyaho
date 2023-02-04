//
//  LinkMemoView.swift
//  ViewerScene
//
//  Created by sudo.park on 2023/02/04.
//

import SwiftUI
import Combine

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


final class LinkMemoViewState: ObservableObject {
    
    @Published var text: String = ""
    @Published var confirmable: Bool = false
    
    func bind(_ viewModel: LinkMemoViewModel) {
        
        viewModel.confirmSavable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] newValue in
                self?.confirmable = newValue
            })
            .disposed(by: self.diposeBag)
        
        self.text = viewModel.initialText ?? ""
        self.textBinding = $text
            .sink(receiveValue: { [weak viewModel] text in
                viewModel?.updateContent(text)
            })
    }
    
    private var textBinding: AnyCancellable?
    private let diposeBag = DisposeBag()
    private var didBind = false
}

public struct LinkMemoView: View {
    
    private let viewModel: LinkMemoViewModel
    @StateObject var state: LinkMemoViewState = .init()
    
    init(viewModel: LinkMemoViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Views.BaseBottomSlideMenuView {
            VStack {
                self.upperHeaderView
                
                self.memoEditView
                
                Views.ConfirmButton(isEnabled: $state.confirmable) {
                    viewModel.confirmSave()
                }
                .padding(.top, 20)
            }
            .padding(.init(top: 24, leading: 20, bottom: 20, trailing: 20))
        } outsideTap: {
            viewModel.close()
        }
        .onAppear {
            self.state.bind(self.viewModel)
        }
    }
    
    private var upperHeaderView: some View {
        HStack {
            Text("Memo".localized)
                .smallHeader()
            Spacer()
            Button {
                viewModel.deleteMemo()
            } label: {
                Text("Delete".localized)
            }
        }
    }
    
    private var memoEditView: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $state.text)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                .frame(height: 300)
            
            if state.text.isEmpty {
                Text("place holder")
                .placeHolder()
                .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 0))
            }
        }
    }
}

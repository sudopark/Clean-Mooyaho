//
//  
//  ManageAccountView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/02/13.
//
//


import UIKit
import SwiftUI

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - ManageAccountViewController

public final class ManageAccountViewStateObject: ObservableObject {
    
    @Published var sections: [ManageAccountCellViewModel.Section] = []
    @Published var isPricessing = false
    
    private let disposeBag = DisposeBag()
    private var didBind = false
    
    public func bind(_ viewModel: ManageAccountViewModel) {
        
        guard self.didBind == false else { return }
        self.didBind = true
        
        let asSection: ([[ManageAccountCellViewModel]]) -> [ManageAccountCellViewModel.Section]
        asSection = { cellViewModelLists in
            return cellViewModelLists.enumerated()
                .map {
                    ManageAccountCellViewModel.Section(sectionNumber: $0.offset, cellViewModels: $0.element)
                }
        }
        
        viewModel.cellViewModels
            .map(asSection)
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] sections in
                self?.sections = sections
            })
            .disposed(by: self.disposeBag)
        
        viewModel.isProcessing
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isProcessing in
                self?.isPricessing = isProcessing
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - ManageAccountView

public struct ManageAccountView: View {
    
    private let viewModel: ManageAccountViewModel
    @StateObject var states: ManageAccountViewStateObject = .init()
    
    public init(viewModel: ManageAccountViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                self.listView()
                self.loadingView()
            }
        }
        .onAppear {
            self.states.bind(self.viewModel)
        }
    }
    
    private func listView() -> some View {
        List(self.states.sections) { section in
            Section {
                ForEach(section.cellViewModels) {
                    self.cell(for: $0)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .removeSeperator()
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Manage Account".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: self.backButton)
    }
    
    private func loadingView() -> some View {
        Views.FullScreenLoadingView(isLoading: $states.isPricessing)
    }
    
    private func cell(for cellViewModel: ManageAccountCellViewModel) -> some View {
        switch cellViewModel {
        case .signout:
            return self.nameCell("Signout".localized, color: self.uiContext.colors.text.asColor)
                .onTapGesture {
                    self.viewModel.signout()
                }
                .asAny()
            
        case .withdrawal:
            return self.nameCell("Delete account".localized, color: .red)
                .onTapGesture {
                    self.viewModel.withdrawal()
                }
                .asAny()
            
        case .withdrawalDescription:
            return self.descriptionCell()
                .asAny()
        }
    }
    
    private func nameCell(_ name: String, color: Color) -> some View {
        HStack {
            Text(name).foregroundColor(color)
            Spacer()
        }
        .padding(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(self.uiContext.colors.raw.tertiarySystemBackground.asColor)
    }
    
    private func descriptionCell() -> some View {
        Views.DescriptionTipsView("delete_ccount_descriptions".localized.components(separatedBy: "\n"))
            .padding(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
    
    
    private var backButton: some View {
        BackButton { self.viewModel.close() }
    }
}


extension ManageAccountCellViewModel: Identifiable {
    
    public var id: String {
        return self.rawValue
    }
    
    struct Section: Identifiable {
        
        let sectionNumber: Int
        let cellViewModels: [ManageAccountCellViewModel]
        
        var id: Int {
            var hasher = Hasher()
            hasher.combine(self.sectionNumber)
            hasher.combine(self.cellViewModels.map { $0.id } )
            return hasher.finalize()
        }
    }
}


struct ManageAccountView_Preview: PreviewProvider {
    
    final class ViewModel: ManageAccountViewModel {
        
        func signout() { }
        func withdrawal() { }
        func close() { }
        
        var cellViewModels: Observable<[[ManageAccountCellViewModel]]> {
            return .just([
                [.signout],
                [.withdrawal, .withdrawalDescription]
            ])
        }
        
        var isProcessing: Observable<Bool> {
            return .just(false)
        }
    }
    
    static var previews: some View {
        let viewModel = ViewModel()
        return ManageAccountView(viewModel: viewModel)
    }
}


private extension View {
    
    func removeSeperator() -> some View {
        if #available(iOS 15.0, *) {
            return self.listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
                .asAny()
        } else {
            return self
                .asAny()
        }
    }
}

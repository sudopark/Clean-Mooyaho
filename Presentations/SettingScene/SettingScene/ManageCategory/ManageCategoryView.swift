//
//  
//  ManageCategoryView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/02/18.
//
//


import UIKit
import SwiftUI

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - ManageCategoryViewController

public final class ManageCategoryViewStateObject: ObservableObject {
    
    @Published var cellViewModels :[CategoryCellViewModel] = []
    
    public func bind(_ viewModel: ManageCategoryViewModel) {
        
        guard self.didBind == false else { return }
        self.didBind = true
        
        viewModel.cellViewModels
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] cellViewModels in
                self?.cellViewModels = cellViewModels
            })
            .disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    private var didBind = false
}


// MARK: - ManageCategoryView

public struct ManageCategoryView: View {
    
    private let viewModel: ManageCategoryViewModel
    @StateObject var states: ManageCategoryViewStateObject = .init()
    private let throttling = ScrollBottomHitThrottling()
    
    public init(viewModel: ManageCategoryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            CoordinatedScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(states.cellViewModels) {
                        self.rowView($0)
                            .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .onGeometryChanged { geo in
                guard self.throttling.didScrollBottomHit(by: geo) else { return }
                self.viewModel.loadMore()
            }
            .navigationTitle("Category".localized)
            .navigationBarItems(leading: self.backButton())
        }
        .onAppear {
            self.states.bind(self.viewModel)
            self.viewModel.refresh()
        }
    }
    
    private func removeCategory(at indexSet: IndexSet) {
        guard let index = indexSet.first,
              let cellViewModel = states.cellViewModels[safe: index]
        else { return }
        
        self.viewModel.removeCategory(cellViewModel.uid)
    }
}

private extension ManageCategoryView {
    
    func rowView(_ cellViewModel: CategoryCellViewModel) -> some View {
        HStack {
            Text(cellViewModel.name)
                .foregroundColor(.white)
                .font(self.uiContext.fonts.get(14, weight: .regular).asFont)
                .padding(.init(top: 2, leading: 6, bottom: 2, trailing: 6))
                .background(UIColor.from(hex: cellViewModel.colorCode)?.asColor ?? .blue)
                .cornerRadius(3)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .resizable()
                .foregroundColor(self.uiContext.colors.raw.lightGray.asColor)
                .frame(width: 6, height: 12)
        }
        .onTapGesture {
            self.viewModel.editCategory(cellViewModel.uid)
        }
    }
    
    private func backButton() -> some View {
        return BackButton {
            self.viewModel.requestClose()
        }
    }
}


// MARK: - extensions

extension CategoryCellViewModel: Identifiable {
    
    public var id: Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}


struct ManageCategoryView_Preview: PreviewProvider {
    
    final class ViewModel: ManageCategoryViewModel {
        
        let cvms = BehaviorRelay<[CategoryCellViewModel]>(value: [
            .init(uid: "u1", name: "c1", colorCode: "0x121314"),
            .init(uid: "u2", name: "c2", colorCode: "0x221314"),
            .init(uid: "u3", name: "c3", colorCode: "0x321314")
        ])
        
        func refresh() { }
        
        func loadMore() { }
        
        func editCategory(_ uid: String) { }
        
        func removeCategory(_ uid: String) { }
        
        func requestClose() { }
        
        var cellViewModels: Observable<[CategoryCellViewModel]> {
            return self.cvms.asObservable()
        }
        
        
    }
    
    static var previews: some View {
        let vm = ViewModel()
        return ManageCategoryView(viewModel: vm)
    }
}

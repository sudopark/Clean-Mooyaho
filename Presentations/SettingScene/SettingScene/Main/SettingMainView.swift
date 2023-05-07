//
//  SettingMainView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/02/09.
//

import UIKit
import SwiftUI
import Combine

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - SettingMainViewStateObject

@MainActor
public final class SettingMainViewStateObject: ObservableObject {
    
    @Published var sections: [SettingItemSection] = []
    
    private let disposeBag = DisposeBag()
    private var didBind = false
    
    public func bind(_ viewModel: SettingMainViewModel) {
        
        guard self.didBind == false else { return }
        self.didBind = true
        
        viewModel.sections
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] sections in
                self?.sections = sections
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SettingMainView

public struct SettingMainView: View {
    
    private let viewModel: SettingMainViewModel
    @StateObject var states: SettingMainViewStateObject = .init()
    
    public init(viewModel: SettingMainViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            
            List(self.states.sections) { section in
                SettingItemSectionView(section) {
                    self.viewModel.selectItem($0)
                }
            }
            .listStyle(.grouped)
            .navigationBarItems(leading: self.closeButton)
            .navigationTitle("Setting".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.states.bind(self.viewModel)
            self.viewModel.refresh()
        }
    }
    
    private var closeButton: some View {
        Button("Close".localized) { self.viewModel.close() }
    }
}


// MARK: - SettingItemSectionView

struct SettingItemSectionView: View {
    
    private let section: SettingItemSection
    private let itemSelected: ((String) -> Void)
    
    init(_ section: SettingItemSection, _ itemSelected: @escaping (String) -> Void) {
        self.section = section
        self.itemSelected = itemSelected
    }
    
    var body: some View {
        Section {
            ForEach(section.cellViewModels) { cvm in
                SettingItemCellView(cellViewModel: cvm)
                    .onTapGesture {
                        self.itemSelected(cvm.itemID)
                    }
            }
        } header: {
            Text(self.section.title)
        }
    }
}


// MARK: - SettingItemCellView

struct SettingItemCellView: View {

    fileprivate let cellViewModel: SettingItemCellViewModel
    
    var body: some View {
        HStack {
            Text(cellViewModel.title)
                .foregroundColor(self.uiContext.colors.text.asColor)
            Spacer()
            accessoryView()
        }
    }
    
    private func accessoryView() -> some View {
        switch cellViewModel.accessory {
        case .disclosure:
            return Image(systemName: "chevron.right")
                .foregroundColor(self.theme.colors.hintText.asColor)
                .asAny()
            
        case let .accentValue(value):
            return Text(value)
                .listItemAccentText()
                .asAny()
            
        case let .toggle(isOn, handler):
            return Views.HandlerToggle(initialState: isOn, handler)
                .asAny()
        }
    }
}


struct SettingItemCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        let model = SettingItemCellViewModel(
            itemID: "some", title: "title",
            isEnable: false, accessory: .toggle(false, { _ in })
        )
        SettingItemCellView(cellViewModel: model)
            .previewLayout(.fixed(width: 300, height: 70))
    }
}


// MARK: - Helper extensions

extension SettingItemCellViewModel.Accessory: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .disclosure: hasher.combine("disclosure")
        case let .accentValue(value): hasher.combine("accent:\(value)")
        case let .toggle(isOn, _): hasher.combine("toggle:\(isOn)")
        }
    }
}

extension SettingItemCellViewModel: Identifiable {
    
    public var id: Int {
        var hasher = Hasher()
        hasher.combine(itemID)
        hasher.combine(title)
        hasher.combine(isEnable)
        hasher.combine(accessory)
        return hasher.finalize()
    }
}

extension SettingItemSection: Identifiable {
    
    public var id: Int {
        var hasher = Hasher()
        hasher.combine(self.sectionID)
        hasher.combine(self.title)
        hasher.combine(self.cellViewModels.map { $0.id } )
        return hasher.finalize()
    }
}

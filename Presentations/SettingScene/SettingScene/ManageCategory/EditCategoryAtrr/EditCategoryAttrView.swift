//
//  EditCategoryAttrView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/11/06.
//

import UIKit
import SwiftUI
import Combine

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - EditCategoryAttrViewState
@MainActor
public final class EditCategoryAttrViewState: ObservableObject {
    
    @Published var isSavable: Bool = false
    @Published var selectedColorCode: String?
    @Published var enteredName: String = ""
    
    func bind(_ viewModel: EditCategoryAttrViewModel) {
        
        viewModel.isChangeSavable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] flag in
                self?.isSavable = flag
            })
            .disposed(by: self.disposeBag)
                
        viewModel.selectedColorCode
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] code in
                self?.selectedColorCode = code
            })
            .disposed(by: self.disposeBag)
        
        self.enteredName = viewModel.initialName
        self.nameEntering = $enteredName
            .sink(receiveValue: { [weak viewModel] name in
                viewModel?.enter(name: name)
            })
    }
    
    private var nameEntering: AnyCancellable?
    private let disposeBag = DisposeBag()
    private var didBind = false
}


public struct EditCategoryAttrView: View {
    
    private let viewModel: EditCategoryAttrViewModel
    @StateObject var state: EditCategoryAttrViewState = .init()

    public init(viewModel: EditCategoryAttrViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Views.BaseBottomSlideMenuView {
            VStack {
                HStack {
                    Text("Edit category".localized)
                        .smallHeader()
                    Spacer()
                }
                .padding(.bottom, 16)
                .padding(.top, 20)
                
                TextField("Enter a name".localized, text: $state.enteredName)
                    .font(theme.fonts.get(14, weight: .regular).asFont)
                    .padding(.vertical, 12)
                    .autocorrectionDisabled(true)
                
                Divider()
                
                ColorSelectRow(selectedColorCode: state.selectedColorCode)
                    .onTapGesture {
                        viewModel.selectNewColor()
                    }
                Divider()
                
                DeleteRow()
                    .onTapGesture {
                        viewModel.delete()
                    }
                
                Views.ConfirmButton(isEnabled: $state.isSavable) {
                    viewModel.confirmSaveChange()
                }
                .padding(.top, 16)
            }
            .padding([.horizontal, .bottom], 20)
            .onAppear {
                self.state.bind(self.viewModel)
            }
        }
    }
    
    private struct ColorSelectRow: View {
        
        var selectedColorCode: String?
        
        var body: some View {
            HStack {
                Image(systemName: "eyedropper")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(self.theme.colors.secondaryTitle.asColor)
                Text("Change a color".localized)
                    .listSectionTitle()
                Spacer()
                Circle().fill (
                    self.selectedColorCode.flatMap(UIColor.from(hex:))?.asColor ?? .clear
                )
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 8)
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(theme.colors.raw.lightGray.asColor)
                    .frame(width: 6, height: 12)
            }
            .padding(.vertical, 12)
        }
    }
    
    private struct DeleteRow: View {
        var body: some View {
            HStack {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(self.theme.colors.secondaryTitle.asColor)
                Text("Delete".localized)
                    .listSectionTitle()
                Spacer()
            }
            .padding(.vertical, 12)
        }
    }
}

//struct EditCategoryAttrView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditCategoryAttrView()
//    }
//}

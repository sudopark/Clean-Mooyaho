//
//  
//  EditProfileView.swift
//  MemberScenes
//
//  Created by sudo.park on 2022/02/16.
//
//


import UIKit
import SwiftUI

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - EditProfileViewController

public final class EditProfileViewStateObject: ObservableObject {
    
    @Published var thumbnail: Thumbnail?
    @Published var cellViewModels: [EditProfileCellViewModel] = []
    @Published var isSavable: Bool = false
    @Published var isSaveChanges: Bool = false
    
    public func bind(_ viewModel: EditProfileViewModel) {
        
        guard self.didBind == false else { return }
        self.didBind = true
        
        viewModel.profileImageSource
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] thumbnail in
                self?.thumbnail = thumbnail
            })
            .disposed(by: self.disposeBag)
        
        viewModel.cellViewModels
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] cellViewModels in
                self?.cellViewModels = cellViewModels
            })
            .disposed(by: self.disposeBag)
        
        viewModel.isSavable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isSavable in
                self?.isSavable = isSavable
            })
            .disposed(by: self.disposeBag)
        
        viewModel.isSaveChanges
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isSaveChanges in
                self?.isSaveChanges = isSaveChanges
            })
            .disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    private var didBind = false
}


// MARK: - EditProfileView

public struct EditProfileView: View {
    
    private let viewModel: EditProfileViewModel
    @StateObject var states: EditProfileViewStateObject = .init()
    
    public init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            List {
                self.profileHeaderView(self.states.thumbnail)
                ForEach(self.states.cellViewModels) { textCell($0) }
                    .listRowBackground(self.uiContext.colors.appSecondBackground.asColor)
            }
            .listStyle(.plain)
            .navigationTitle("Edit Profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: closeButton, trailing: saveButton)
        }
        .onAppear {
            self.states.bind(self.viewModel)
        }
    }
}


extension EditProfileView {
    
    private var closeButton: some View {
        Button("Close".localized) {
            self.viewModel.requestCloseScene()
        }
    }
    
    private var saveButton: some View {
        Button("Save".localized) {
            self.viewModel.saveChanges()
        }
        .disabled(self.states.isSavable == false)
    }
    
    func profileHeaderView(_ thumbnail: Thumbnail?) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile image".localized)
                    .listItemTitle()
                Text("You can choose a photo or emoji as a profile image.".localized)
                    .listItemDescription()
            }
            Spacer()
            ZStack {
                Circle()
                    .strokeBorder(self.uiContext.colors.appSecondBackground.asColor, lineWidth: 1)
                    .frame(width: 100, height: 100)
                
                Views.IntegratedImageView(
                    .constant(thumbnail),
                    resize: .init(width: 98, height: 98),
                    backgroundColor: self.uiContext.colors.appBackground.asColor
                )
                .frame(width: 98, height: 98)
                .clipShape(Circle())
            }
            .onTapGesture {
                self.viewModel.requestChangeThumbnail()
            }
        }
        .padding(.init(top: 20, leading: 0, bottom: 20, trailing: 0))
    }
    
    func textCell(_ cellViewModel: EditProfileCellViewModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 2) {
                    Text(cellViewModel.inputType.title)
                        .listItemTitle()
                        .lineLimit(1)
                    if cellViewModel.isRequire {
                        Text("*")
                            .font(self.uiContext.fonts.get(14, weight: .medium).asFont)
                            .foregroundColor(.red)
                            .offset(y: 2)
                    }
                }
                Text(cellViewModel.value ?? cellViewModel.inputType.placeHolder)
                    .font(self.uiContext.fonts.get(15, weight: .regular).asFont)
                    .foregroundColor(
                        cellViewModel.value != nil
                            ? self.uiContext.colors.text.asColor
                            : self.uiContext.colors.descriptionText.asColor
                    )
                    .lineLimit(1)
            }
            
            Spacer(minLength: 16)
            
            Image(systemName: "chevron.right")
                .resizable()
                .foregroundColor(self.uiContext.colors.raw.lightGray.asColor)
                .frame(width: 6, height: 12)
        }
        .onTapGesture {
            self.viewModel.requestChangeProperty(cellViewModel.inputType)
        }
    }
}


// MARK: - extension

extension EditProfileCellViewModel: Identifiable {
    
    public var id: Int {
        var hasher = Hasher()
        hasher.combine(self.inputType.rawValue)
        hasher.combine(self.value)
        hasher.combine(self.isRequire)
        return hasher.finalize()
    }
}

private extension EditProfileCellViewModel.InputType {
    
    var placeHolder: String {
        switch self {
        case .nickname: return "Please set a nickname of 30 characters or less".localized
        case .intro: return "Please introduce yourself in 300 characters or less.".localized
        }
    }
    
    var title: String {
        switch self {
        case .nickname: return "Nickname".localized
        case .intro: return "Introduction".localized
        }
    }
}


struct EditProfileView_Preview: PreviewProvider {
    
    final class DummyViewModel: EditProfileViewModel {
        
        func requestChangeThumbnail() { }
        
        func requestChangeProperty(_ inputType: EditProfileCellViewModel.InputType) { }
        
        func saveChanges() { }
        
        func requestCloseScene() { }
        
        var profileImageSource: Observable<Thumbnail?> {
            return .just(.emoji("🤑"))
        }
        
        var cellViewModels: Observable<[EditProfileCellViewModel]> {
            return .just([
                .init(inputType: .nickname, value: nil, isRequire: true),
                .init(inputType: .intro, value: nil, isRequire: false)
            ])
        }
        
        var isSavable: Observable<Bool> {
            return .just(false)
        }
        
        var isSaveChanges: Observable<Bool> {
            return .just(false)
        }
        
        
    }
    
    static var previews: some View {
        let viewModel = DummyViewModel()
        return EditProfileView(viewModel: viewModel)
    }
}

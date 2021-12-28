//
//  EditProfileView.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


final class EditProfileView: BaseUIView {
    
    final class ProfileImageHeaderView: BaseUIView, Presenting, UITextFieldDelegate {
        
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        
        let borderView = UIView()
        let imageView = IntegratedImageView()
        
        func setupLayout() {
            
            self.addSubview(borderView)
            borderView.autoLayout.active(with: self) {
                $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
                $0.heightAnchor.constraint(equalToConstant: 100)
                $0.widthAnchor.constraint(equalToConstant: 100)
            }
            
            self.addSubview(titleLabel)
            titleLabel.autoLayout.active(with: self) {
                $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
                $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
                $0.trailingAnchor.constraint(lessThanOrEqualTo: borderView.leadingAnchor, constant: -8)
            }
            
            self.addSubview(descriptionLabel)
            descriptionLabel.autoLayout.active(with: self) {
                $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
                $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
                $0.trailingAnchor.constraint(lessThanOrEqualTo: borderView.leadingAnchor, constant: -20)
            }
            
            self.borderView.addSubview(imageView)
            self.imageView.autoLayout.fill(borderView, edges: .init(top: 1, left: 1, bottom: 1, right: 1))
            self.imageView.setupLayout()
        }
        
        func setupStyling() {
            
            self.backgroundColor = self.uiContext.colors.appBackground
            
            _ = self.titleLabel
                |> self.uiContext.decorating.listItemTitle(_:)
                |> \.numberOfLines .~ 1
                |> \.text .~ pure("Profile image".localized)
            
            _ = self.descriptionLabel
                |> self.uiContext.decorating.listItemDescription
                |> \.numberOfLines .~ 0
                |> \.text .~ pure("You can choose a photo or emoji as a profile image.".localized)
            
            self.imageView.setupStyling()
            self.imageView.backgroundColor = self.uiContext.colors.appBackground
            self.imageView.layer.cornerRadius = 49
            self.imageView.clipsToBounds = true
            
            self.borderView.backgroundColor = self.uiContext.colors.appSecondBackground
            self.borderView.layer.cornerRadius = 50
            self.borderView.clipsToBounds = true
        }
    }
    
    final class InputTextCell: BaseTableViewCell, Presenting {
        
        let keyLabel = UILabel()
        let valueLabel = UILabel()
        let requireAccetLabel = UILabel()
        
        func setupCell(_ cellViewModel: EditProfileCellViewModel) {
            self.keyLabel.text = cellViewModel.inputType.title
            self.valueLabel.text = cellViewModel.value ?? cellViewModel.inputType.placeHolder
            self.requireAccetLabel.isHidden = cellViewModel.isRequire == false
        }
        
        override func afterViewInit() {
            super.afterViewInit()
            self.setupLayout()
            self.setupStyling()
        }
        
        func setupLayout() {
            
            self.contentView.addSubview(keyLabel)
            keyLabel.autoLayout.active(with: self.contentView) {
                $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
                $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            }
            keyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            
            self.contentView.addSubview(requireAccetLabel)
            requireAccetLabel.autoLayout.active(with: self.contentView) {
                $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -16)
                $0.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 2)
                $0.topAnchor.constraint(equalTo: keyLabel.topAnchor, constant: 2)
            }
            keyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            
            self.contentView.addSubview(valueLabel)
            valueLabel.autoLayout.active(with: self.contentView) {
                $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
                $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
                $0.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 4)
                $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -6)
            }
        }
        
        func setupStyling() {
            self.backgroundColor = self.uiContext.colors.appSecondBackground
            
            _ = keyLabel
                |> self.uiContext.decorating.listItemTitle(_:)
                |> \.numberOfLines .~ 1
            
            _ = self.requireAccetLabel
                |> \.font .~ self.uiContext.fonts.get(14, weight: .medium)
                |> \.textColor .~ UIColor.systemRed
                |> \.text .~ "*"
                |> \.isHidden .~ true
            
            _ = valueLabel
                |> self.uiContext.decorating.listItemTitle(_:)
                |>  \.font .~ self.uiContext.fonts.get(15, weight: .regular)
                |> \.numberOfLines .~ 1
            
            self.accessoryType = .disclosureIndicator
        }
    }
    
    let closeButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let titleLabel = UILabel()
    
    let profileHeaderView = ProfileImageHeaderView()
    let tableView = UITableView()
}


extension EditProfileView: Presenting {
    
    func setupLayout() {
        
        let topView = UIView()
        self.addSubview(topView)
        topView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        
        topView.addSubview(closeButton)
        closeButton.autoLayout.active(with: topView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -12)
        }
        
        topView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: topView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        topView.addSubview(saveButton)
        saveButton.autoLayout.active(with: topView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.addSubview(tableView)
        tableView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: topView.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.tableView.tableHeaderView = profileHeaderView
        profileHeaderView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
            $0.widthAnchor.constraint(equalTo: tableView.widthAnchor)
            $0.topAnchor.constraint(equalTo: tableView.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 120)
        }
        profileHeaderView.setupLayout()
    }
    
    func setupStyling() {
        
        self.closeButton.setTitle("Close".localized, for: .normal)
        
        self.titleLabel.text = "Edit Profile".localized
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.textAlignment = .center
        
        self.saveButton.setTitle("Save".localized, for: .normal)
        self.saveButton.isEnabled = false
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.tableView.registerCell(InputTextCell.self)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.separatorStyle = .none
        
        self.profileHeaderView.setupStyling()
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

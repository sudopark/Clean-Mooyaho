//
//  EditProfileView.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


final class EditProfileView: BaseUIView {
    
    final class ProfileImageHeaderView: BaseUIView, Presenting {
        
        let borderView = UIView()
        let imageView = IntegratedImageView()
        let emojiInput = EmojiInputTextFiled()
        
        func setupLayout() {
            self.addSubview(borderView)
            borderView.autoLayout.active(with: self) {
                $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
                $0.heightAnchor.constraint(equalTo: $1.heightAnchor, multiplier: 0.75)
                $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
            }
            
            self.borderView.addSubview(emojiInput)
            emojiInput.autoLayout.active(with: self) {
                $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
                $0.widthAnchor.constraint(equalToConstant: 20)
                $0.heightAnchor.constraint(equalToConstant: 20)
            }
            
            self.borderView.addSubview(imageView)
            imageView.autoLayout.activeFill(borderView, edges: .init(top: 1, left: 1, bottom: 1, right: 1))
        }
        
        func setupStyling() {
            
            self.backgroundColor = self.uiContext.colors.appBackground
            
            self.borderView.backgroundColor = self.uiContext.colors.text
            
            self.emojiInput.allowsEditingTextAttributes = true
            self.emojiInput.alpha = 0.01
            
            self.imageView.backgroundColor = UIColor.red
        }
    }
    
    final class InputTextCell: BaseTableViewCell, Presenting {
        
        let inputTextField: UITextField = .init()
        
        override func afterViewInit() {
            super.afterViewInit()
            self.setupLayout()
            self.setupStyling()
        }
        
        func setupLayout() {
            self.contentView.addSubview(inputTextField)
            inputTextField.autoLayout.active(with: self.contentView) {
                $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
                $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 4)
                $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
                $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -4)
            }
        }
        
        func setupStyling() {
            self.backgroundColor = self.uiContext.colors.appSecondBackground
            
            self.inputTextField.textColor = self.uiContext.colors.text
        }
    }
    
    let closeButton = UIButton()
    let saveButton = UIButton()
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
            $0.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            $0.topAnchor.constraint(equalTo: tableView.topAnchor)
            $0.heightAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.6)
        }
        profileHeaderView.setupLayout()
    }
    
    func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.tableView.registerCell(InputTextCell.self)
        self.tableView.estimatedRowHeight = 65
    }
}

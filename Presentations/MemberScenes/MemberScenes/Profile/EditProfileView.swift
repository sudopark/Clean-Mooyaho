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
    
    final class ProfileImageHeaderView: BaseUIView, Presenting, UITextFieldDelegate {
        
        let borderView = UIView()
        let imageView = IntegratedImageView()
        let emojiInput = EmojiInputTextFiled()
        
        func setupLayout() {
            self.addSubview(borderView)
            borderView.autoLayout.active(with: self) {
                $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
                $0.heightAnchor.constraint(equalToConstant: 150)
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
            self.imageView.autoLayout.activeFill(borderView, edges: .init(top: 1, left: 1, bottom: 1, right: 1))
            self.imageView.setupLayout()
        }
        
        func setupStyling() {
            
            self.backgroundColor = self.uiContext.colors.appBackground
            
            self.imageView.setupStyling()
            self.imageView.backgroundColor = self.uiContext.colors.appBackground
            self.imageView.layer.cornerRadius = 74
            self.imageView.clipsToBounds = true
            
            self.borderView.backgroundColor = self.uiContext.colors.appSecondBackground
            self.borderView.layer.cornerRadius = 75
            self.borderView.clipsToBounds = true
            
            self.emojiInput.delegate = self
            
            self.emojiInput.allowsEditingTextAttributes = true
            self.emojiInput.alpha = 0.01
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            textField.text = ""
            return true
        }
    }
    
    final class InputTextCell: BaseTableViewCell, Presenting {
        
        let inputTextField: UITextField = .init()
        weak var inputListener: PublishSubject<(EditProfileCellType, String)>?
        
        func setupCell(_ type: EditProfileCellType,
                       previousInput: String?,
                       listener: PublishSubject<(EditProfileCellType, String)>?) {
            self.inputListener = listener
            
            self.inputTextField.placeholder = type.placeHolder
            self.inputTextField.text = previousInput
            
            self.inputTextField.rx.text.orEmpty
                .subscribe(onNext: { [weak self] text in
                    self?.inputListener?.onNext((type, text))
                })
                .disposed(by: self.disposeBag)
        }
        
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
            self.inputTextField.autocorrectionType = .no
            self.inputTextField.autocapitalizationType = .none
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
            $0.heightAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.6)
        }
        profileHeaderView.setupLayout()
    }
    
    func setupStyling() {
        
        self.closeButton.setTitle("Close".localized, for: .normal)
        
        self.titleLabel.text = "Edit Profile"
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.textAlignment = .center
        
        self.saveButton.setTitle("Save".localized, for: .normal)
        self.saveButton.isEnabled = false
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.tableView.registerCell(InputTextCell.self)
        self.tableView.estimatedRowHeight = 65
        self.tableView.separatorStyle = .none
        
        self.profileHeaderView.setupStyling()
    }
}


private extension EditProfileCellType {
    
    var placeHolder: String {
        switch self {
        case .nickName: return "nickname".localized
        case .introduction: return "introduce".localized
        }
    }
}

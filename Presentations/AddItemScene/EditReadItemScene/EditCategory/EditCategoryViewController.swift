//
//  EditCategoryViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


// MARK: - EditCategoryViewController

public final class EditCategoryViewController: BaseViewController, EditCategoryScene {
    
    private let titleLabel = UILabel()
    private let inputField = SingleLineInputView()
    private var selectedCollectionView: UICollectionView!
    private let tableView = UITableView()
    private let confirmButton = ConfirmButton()
    private var tableViewTopConstraint: NSLayoutConstraint!
    
    let viewModel: EditCategoryViewModel
    
    public init(viewModel: EditCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
}

// MARK: - bind

extension EditCategoryViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension EditCategoryViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        }
        
        self.view.addSubview(inputField)
        inputField.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -10)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32)
        }
        inputField.setupLayout()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view.addSubview(selectedCollectionView)
        selectedCollectionView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            $0.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 12)
            $0.heightAnchor.constraint(equalToConstant: 32)
        }
        
        self.view.addSubview(tableView)
        tableViewTopConstraint = tableView.autoLayout.make(with: inputField) {
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor, constant: 12)
        }.first
        tableViewTopConstraint.isActive = true
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
    }
    
    public func setupStyling() {
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Choose a category"
        
        self.inputField.setupStyling()
        self.inputField.backgroundColor = .clear
        self.inputField.placeHolderLabel.text = "Enter a name"
        
        self.selectedCollectionView.registerCell(SelectedCategoryCell.self)
        self.selectedCollectionView.delegate = self
        
        self.tableView.registerCell(SuggestingCategoryCell.self)
        self.tableView.registerCell(SuggestMakeNewCategoryCell.self)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: -60, right: 0)
    }
}


// MARK: - collectionView delegate

extension EditCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}


// MARK: - tableview delegate

extension EditCategoryViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

//
//  EditProfileViewController.swift
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import Domain
import CommonPresenting


// MARK: - EditProfileViewController

public final class EditProfileViewController: BaseViewController, EditProfileScene {
    
    typealias Sections = SectionModel<String, EditProfileCellType>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Sections>
    
    let editView = EditProfileView()
    
    let viewModel: EditProfileViewModel
    private var dataSource: DataSource!
    private let cellInputListener = PublishSubject<(EditProfileCellType, String)>()
    
    public init(viewModel: EditProfileViewModel) {
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

extension EditProfileViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
                self?.bindEmojiInput()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isSavable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.editView.saveButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        // TODO: show is Saving
        
        self.editView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.requestCloseScene()
            })
            .disposed(by: self.disposeBag)
        
        self.editView.saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.saveChanges()
            })
            .disposed(by: self.disposeBag)
        
        self.cellInputListener
            .subscribe(onNext: { [weak self] pair in
                self?.viewModel.inputTextChanges(type: pair.0, to: pair.1)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension EditProfileViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(editView)
        editView.autoLayout.fill(self.view)
        editView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        editView.setupStyling()
    }
}


// MARK: - bind tableview

private extension EditProfileViewController {
    
    func makeDataSource() -> DataSource {
        
        return .init { [weak self] _, tableView, indexPath, cellType in
            let cell: EditProfileView.InputTextCell = tableView.dequeueCell()
            cell.setupCell(cellType, previousInput: self?.viewModel.previousInputValue(for: cellType),
                           listener: self?.cellInputListener)
            return cell
        }
    }
    
    func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellTypes
            .map{ [Sections(model: "inputs", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.editView.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
}


// MARK: - bind emoji, memoji input

private extension EditProfileViewController {
    
    func bindEmojiInput() {
        
        self.viewModel.profileImageSource
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] source in
                if let source = source {
                    self?.editView.profileHeaderView.imageView.setupImage(using: source)
                } else {
                    self?.editView.profileHeaderView.imageView.cancelSetupImage()
                }
            })
            .disposed(by: self.disposeBag)
        
        
        self.editView.profileHeaderView.emojiInput.newInputEmoji
            .subscribe(onNext: { [weak self] emoji in
                self?.editView.profileHeaderView.imageView.setupImage(using: .emoji(emoji))
                self?.viewModel.selectEmoji(emoji)
            })
            .disposed(by: self.disposeBag)
        
        self.editView.profileHeaderView.emojiInput.newInputMemoji
            .subscribe(onNext: { [weak self] image in
                guard let data = image.pngData() else { return }
                let size = ImageSize(Double(image.size.width), Double(image.size.height))
                self?.editView.profileHeaderView.imageView.drawImage(image)
                self?.viewModel.selectMemoji(data, size: size)
            })
            .disposed(by: self.disposeBag)
        
        self.editView.profileHeaderView.imageView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.editView.profileHeaderView.emojiInput.becomeFirstResponder()
            })
            .disposed(by: self.disposeBag)
        
        self.view.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
    }
}

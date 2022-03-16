//
//  NavigateCollectionViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting

// MARK: - NavigateCollectionViewController

public final class NavigateCollectionViewController: BaseViewController, NavigateCollectionScene {
    
    typealias CVM = NavigateCollectionCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView()
    private let confirmButton = ConfirmButton()
    
    let viewModel: NavigateCollectionViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: NavigateCollectionViewModel) {
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
        self.viewModel.reloadCollections()
        self.viewModel.requestPrepareParentIfNeed()
    }
    
}

// MARK: - bind

extension NavigateCollectionViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.confirmTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.confirmButton.title = title
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.isEnabled = self.viewModel.isParentChangable
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map { [Section(model: "Collections".localized, items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.moveToSubCollection(cellViewModel.uid)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        
        let configureCell: DataSource.ConfigureCell = { _, tableView, _, cellViewModel in
            let cell: NavigateCollectionCell = tableView.dequeueCell()
            cell.setupCell(cellViewModel)
            return cell
        }
        
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension NavigateCollectionViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view, withSafeArea: true)
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        confirmButton.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.title = "Select a collection".localized
        
        self.tableView.registerCell(NavigateCollectionCell.self)
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        self.tableView.separatorStyle = .none
        
        self.confirmButton.setupStyling()
    }
}


typealias NavigateCollectionCell = SimpleReadCollectionCell


extension NavigateCollectionCell {
    
    func setupCell(_ cellViewModel: NavigateCollectionCellViewModel) {
        self.shrinkView.nameLabel.text = cellViewModel.name
        
        self.updateDescription(cellViewModel.description)
    }
}

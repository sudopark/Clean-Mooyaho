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
import Prelude
import Optics

import CommonPresenting

// MARK: - NavigateCollectionViewController

public final class NavigateCollectionViewController: BaseViewController, NavigateCollectionScene {
    
    typealias CVM = NavigateCollectionCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView()
    private let confirmButton = ConfirmButton()
    private let emptyView = UIView()
    private let emptyLabel = UILabel()
    
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
        
        self.viewModel.collectionTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.title = title
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
            .do(onNext: { [weak self] sections in
                self?.updateIsEmpty(sections)
            })
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
    
    private func updateIsEmpty(_ sections: [Section]) {
        let itemCount = sections.first?.items.count ?? 0
        self.emptyView.isHidden = itemCount > 0
    }
}

// MARK: - setup presenting

extension NavigateCollectionViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: -60)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        confirmButton.setupLayout()
        
        self.view.addSubview(emptyView)
        emptyView.autoLayout.active(with: tableView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: confirmButton.topAnchor)
        }
        
        self.emptyView.addSubview(emptyLabel)
        emptyLabel.autoLayout.active(with: self.emptyView) {
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -20)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 10)
        }
        _ = self.emptyLabel
            |> self.uiContext.decorating.placeHolder
            |> \.text .~ pure("Sub reading list does not exist.".localized)
            |> \.textAlignment .~ .center
        self.emptyView.isHidden = true
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
        
        self.shrinkView.alpha = cellViewModel.isSelectable ? 1.0 : 0.4
    }
}

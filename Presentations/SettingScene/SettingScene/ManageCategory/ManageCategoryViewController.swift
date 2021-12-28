//
//  ManageCategoryViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - ManageCategoryViewController

public final class ManageCategoryViewController: BaseViewController, ManageCategoryScene, ShrinkableTtileHeaderViewSupporting {
    
    typealias CVM = CategoryCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    public let titleHeaderView: BaseTableViewHeaderView = BaseTableViewHeaderView()
    private let tableView = UITableView()
    public var titleHeaderViewRelatedScrollView: UIScrollView { self.tableView }
    
    let viewModel: ManageCategoryViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: ManageCategoryViewModel) {
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
        viewModel.refresh()
    }
    
}

// MARK: - bind

extension ManageCategoryViewController {
    
    private func bind() {
     
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map { [Section(model: "categories", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.editCategory(cellViewModel.uid)
            })
            .disposed(by: self.disposeBag)
        
        let waitForDragging = self.tableView.rx.willBeginDragging.take(1)
        self.tableView.rx.scrollBottomHit(wait: waitForDragging, threshold: 20)
            .debounce(.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadMore()
            })
            .disposed(by: self.disposeBag)
        
        self.bindUpdateTitleheaderViewByScroll(with: .just("Category".localized))
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { _, tableView, indexPath, cellViewModel in
            let cell: CategoryCell = tableView.dequeueCell()
            cell.labelView.setup(name: cellViewModel.name)
            cell.labelView.backgroundColor = UIColor.from(hex: cellViewModel.colorCode)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        return DataSource(configureCell: configureCell)
    }
}

// MAR: = tableview delegate

extension ManageCategoryViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.dataSource[indexPath]
        
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, handler in
            handler(false)
            self?.viewModel.removeCategory(item.uid)
        }
        action.image = UIImage(systemName: "trash.fill")
        let configure = UISwipeActionsConfiguration(actions: [action])
        configure.performsFirstActionWithFullSwipe = false
        return configure
    }
}

// MARK: - setup presenting

extension ManageCategoryViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.tableView.tableHeaderView = self.titleHeaderView
        titleHeaderView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
            $0.widthAnchor.constraint(equalTo: tableView.widthAnchor)
            $0.topAnchor.constraint(equalTo: tableView.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        titleHeaderView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.tableView.registerCell(CategoryCell.self)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        self.titleHeaderView.setupStyling()
    }
}


// MARK: - CategoryCell

final class CategoryCell: BaseTableViewCell, Presenting {
    
    let labelView = CategoryLabelView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
}

extension CategoryCell {
    
    func setupLayout() {
        self.contentView.addSubview(labelView)
        labelView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
        }
        labelView.setupLayout()
    }
    
    func setupStyling() {
        self.labelView.setupStyling()
        self.labelView.updateCloseViewIsHidden(true)
    }
}

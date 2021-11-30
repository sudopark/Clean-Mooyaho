//
//  FavoriteItemsViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/12/01.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - FavoriteItemsViewController

public final class FavoriteItemsViewController: BaseViewController, FavoriteItemsScene, ReadCollectionTtileHeaderViewSupporting {
    
    private typealias CVM = ReadItemCellViewModel
    private typealias Section = SectionModel<String, CVM>
    private typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    public let titleHeaderView = ReadCollectionTtileHeaderView()
    private let tableView = UITableView()
    public var titleHeaderViewRelatedScrollView: UIScrollView { self.tableView }
    
    let viewModel: FavoriteItemsViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: FavoriteItemsViewModel) {
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
        self.viewModel.refreshList()
    }
    
}

// MARK: - bind

extension FavoriteItemsViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
                self?.bindUpdateTitleheaderViewByScroll(with: .just("Favorite items".localized))
            })
            .disposed(by: self.disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshList()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map { [Section(model: "favorites", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                switch cellViewModel {
                case let collection as ReadCollectionCellViewModel:
                    self?.viewModel.selectCollection(collection.uid)
                    
                case let link as ReadLinkCellViewModel:
                    self?.viewModel.selectLink(link.uid)
                    
                default: return
                }
            })
            .disposed(by: self.disposeBag)
        
        let userDragging = self.tableView.rx.willBeginDragging.take(1)
        self.tableView.rx.scrollBottomHit(wait: userDragging, threshold: 100)
            .debounce(.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadMore()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewModel in
            guard let self = self else { return UITableViewCell() }
            
            switch cellViewModel {
            case let collection as ReadCollectionCellViewModel:
                let cell: DefaultReadCollectionCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell
                
            case let link as ReadLinkCellViewModel:
                let cell: DefaultReadLinkCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.readLinkPreview(for: link.uid),
                                 customTitle: link.customName)
                return cell
            default: return UITableViewCell()
            }
        }
        return .init(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension FavoriteItemsViewController: Presenting {
    
    
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
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        
        self.tableView.registerCell(DefaultReadCollectionCell.self)
        self.tableView.registerCell(DefaultReadLinkCell.self)
        
        self.titleHeaderView.setupStyling()
        
        let refreshButton = UIBarButtonItem(systemItem: .refresh, primaryAction: nil, menu: nil)
        self.navigationItem.rightBarButtonItem = refreshButton
    }
}

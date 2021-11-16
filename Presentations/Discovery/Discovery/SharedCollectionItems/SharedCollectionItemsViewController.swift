//
//  SharedCollectionItemsViewController.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting

// MARK: - SharedCollectionItemsViewController

public final class SharedCollectionItemsViewController: BaseViewController, SharedCollectionItemsScene, ReadCollectionTtileHeaderViewSupporting {
    
    typealias CVM = ReadItemCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    public let titleHeaderView = ReadCollectionTtileHeaderView()
    let tableView = UITableView()
    public var titleHeaderViewRelatedScrollView: UIScrollView { self.tableView }
    
    let viewModel: SharedCollectionItemsViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: SharedCollectionItemsViewModel) {
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
        
        self.viewModel.reloadCollectionSubItems()
    }
    
}

// MARK: - bind

extension SharedCollectionItemsViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.bindTableView()
                self.bindUpdateTitleheaderViewByScroll(with: self.viewModel.collectionTitle)
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.viewDidAppear()
            })
            .disposed(by: self.disposeBag)
    }
}

extension SharedCollectionItemsViewController: UITableViewDelegate {
    
    private func bindTableView() {
        
        self.dataSource = self.makeCollectionViewDataSource()
        
        self.viewModel.sections
            .map { $0.map{ .init(model: $0.type.rawValue, items: $0.cellViewModels ) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)

        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] model in
                self?.viewModel.openItem(model.uid)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeCollectionViewDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            switch item {
            case let attribute as SharedCollectionAttrCellViewModel:
                let cell: SharedCollectionAttrCell = tableView.dequeueCell()
                cell.setupCell(attribute)
                return cell
            
            case let collection as SharedCollectionCellViewModel where collection.isShrink == false:
                let cell: SharedCollectionExpandCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell
                
            case let collection as SharedCollectionCellViewModel where collection.isShrink == true:
                let cell: SharedShrinkCollectionCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell

            case let link as SharedLinkCellViewModel where link.isShrink == false:
                let cell: SharedLinkExpandCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.linkPreview(for: link.uid), customTitle: link.customName)
                return cell
                
            case let link as SharedLinkCellViewModel where link.isShrink == true:
                let cell: SharedShrinkLinkCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.linkPreview(for: link.uid), customTitle: link.customName)
                return cell

            default: return UITableViewCell()
            }
        }
        return .init(configureCell: configureCell)
    }
    
    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        guard let section = self.dataSource?.sectionModels[safe: section],
              let sectionType = ReadCollectionItemSectionType(rawValue: section.model) else {
            return nil
        }
        return sectionType.makeSectionHeaderIfPossible()
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = self.dataSource?.sectionModels[safe: section],
              let sectionType = ReadCollectionItemSectionType(rawValue: section.model),
              sectionType != .attribute else {
            return 0
        }
        return 40
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView,
                          viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}


// MARK: - setup presenting

extension SharedCollectionItemsViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view, withSafeArea: true)
        
        self.tableView.tableHeaderView = self.titleHeaderView
        titleHeaderView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
            $0.widthAnchor.constraint(equalTo: tableView.widthAnchor)
            $0.topAnchor.constraint(equalTo: tableView.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 60)
        }
        titleHeaderView.setupLayout()
    }
    
    public func setupStyling() {
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        
        self.titleHeaderView.setupStyling()
        
        self.tableView.registerCell(SharedCollectionAttrCell.self)
        self.tableView.registerCell(SharedCollectionExpandCell.self)
        self.tableView.registerCell(SharedLinkExpandCell.self)
        self.tableView.registerCell(SharedShrinkCollectionCell.self)
        self.tableView.registerCell(SharedShrinkLinkCell.self)
    }
}

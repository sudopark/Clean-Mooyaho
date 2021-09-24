//
//  ReadCollectionViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting

// MARK: - ReadCollectionViewController

public final class ReadCollectionViewController: BaseViewController, ReadCollectionScene {
    
    typealias CVM = ReadItemCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private var dataSource: DataSource!
    let viewModel: ReadCollectionViewModel
    
    let titleHeaderView = ReadCollectionTtileHeaderView()
    let tableView = UITableView()
    
    public init(viewModel: ReadCollectionViewModel) {
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

extension ReadCollectionViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
    }
}

extension ReadCollectionViewController: UITableViewDelegate {
    
    private func bindTableView() {
        
        self.dataSource = self.makeCollectionViewDataSource()
        
        self.viewModel.sections
            .map { $0.map{ .init(model: $0.type.rawValue, items: $0.cellViewModels ) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    private func makeCollectionViewDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { _, tableView, indexPath, item in
            switch item {
            case let attribute as ReadCollectionAttrCellViewModel:
                let cell: ReadCollcetionAttrCell = tableView.dequeueCell()
                cell.setupCell(attribute)
                return cell
                
            case let collection as ReadCollectionCellViewModel where collection.isShrink == false:
                let cell: ReadCollectionShrinkCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell

            case let collection as ReadCollectionCellViewModel where collection.isShrink == true:
                let cell: ReadCollectionExpandCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell

            case let link as ReadLinkCellViewModel where link.isShrink == false:
                let cell: ReadLinkShrinkCell = tableView.dequeueCell()
                cell.setupCell(link)
                return cell

            case let link as ReadLinkCellViewModel where link.isShrink == true:
                let cell: ReadLinkExpandCell = tableView.dequeueCell()
                cell.setupCell(link)
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
                          viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - setup presenting

extension ReadCollectionViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view, withSafeArea: true)
        
        self.tableView.tableHeaderView = self.titleHeaderView
        titleHeaderView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
            $0.widthAnchor.constraint(equalTo: tableView.widthAnchor)
            $0.topAnchor.constraint(equalTo: tableView.topAnchor)
            $0.heightAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 0.6)
        }
        titleHeaderView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        
        self.tableView.registerCell(ReadCollcetionAttrCell.self)
        self.tableView.registerCell(ReadCollectionExpandCell.self)
        self.tableView.registerCell(ReadCollectionShrinkCell.self)
        self.tableView.registerCell(ReadLinkExpandCell.self)
        self.tableView.registerCell(ReadLinkShrinkCell.self)
    }
}

private extension ReadCollectionItemSectionType {
    
    func makeSectionHeaderIfPossible() -> ReadCollectionSectionHeaderView? {
        guard self != .attribute else { return nil }
        let header = ReadCollectionSectionHeaderView()
        header.setupTitle(self.rawValue)
        return header
    }
}

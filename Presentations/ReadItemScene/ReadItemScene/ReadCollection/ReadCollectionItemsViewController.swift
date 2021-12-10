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

public final class ReadCollectionItemsViewController: BaseViewController, ReadCollectionScene, ShrinkableTtileHeaderViewSupporting {
    
    typealias CVM = ReadItemCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private var currentCollectionID: String? { self.viewModel.currentCollectionID }
    
    private var dataSource: DataSource!
    let viewModel: ReadCollectionItemsViewModel
    
    public let titleHeaderView = ReadCollectionTtileHeaderView()
    let tableView = UITableView()
    public var titleHeaderViewRelatedScrollView: UIScrollView { self.tableView }
    
    public init(viewModel: ReadCollectionItemsViewModel) {
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
        
        self.viewModel.reloadCollectionItems()
        self.viewModel.requestPrepareParentIfNeed()
    }
    
}

// MARK: - bind

extension ReadCollectionItemsViewController {
    
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
        
        self.viewModel.isEditable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isEditable in
                self?.updateEditButton(by: isEditable)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateEditButton(by isEditable: Bool) {
        
        guard isEditable else {
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        
        let button = UIBarButtonItem(title: "Edit".localized, image: nil, primaryAction: nil, menu: nil)
        self.navigationItem.rightBarButtonItem = button

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.editCollection()
            })
            .disposed(by: self.disposeBag)
    }
}

extension ReadCollectionItemsViewController: UITableViewDelegate {
    
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
            case let attribute as ReadCollectionAttrCellViewModel:
                let cell: ReadCollcetionAttrCell = tableView.dequeueCell()
                cell.setupCell(attribute)
                return cell
            
            case let collection as ReadCollectionCellViewModel where collection.isShrink == false:
                let cell: ReadCollectionExpandCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell
                
            case let collection as ReadCollectionCellViewModel where collection.isShrink == true:
                let cell: ReadItemShrinkCollectionCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell

            case let link as ReadLinkCellViewModel where link.isShrink == false:
                let cell: ReadLinkExpandCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.readLinkPreview(for: link.uid), customTitle: link.customName)
                return cell
                
            case let link as ReadLinkCellViewModel where link.isShrink == true:
                let cell: ReadItemShrinkLinkCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.readLinkPreview(for: link.uid), customTitle: link.customName)
                return cell

            default: return UITableViewCell()
            }
        }
        let canEditRow: DataSource.CanEditRowAtIndexPath = { source, indexPath in
            let item = source[indexPath]
            return item is ReadCollectionCellViewModel || item is ReadLinkCellViewModel
        }
        return .init(configureCell: configureCell, canEditRowAtIndexPath: canEditRow)
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
    
    public func tableView(_ tableView: UITableView,
                          leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.dataSource[indexPath]
        guard let actions = self.viewModel.contextAction(for: item, isLeading: true) else { return nil }
        let actionSelected: (ReadCollectionItemSwipeContextAction) -> Void = { [weak self] selected in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.viewModel.handleContextAction(for: item, action: selected)
            }
        }
        let contextActions = actions.map { $0.asUIContextAction(actionSelected) }
        let configure = UISwipeActionsConfiguration(actions: contextActions)
        configure.performsFirstActionWithFullSwipe = false
        return configure
    }
    
    public func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.dataSource[indexPath]
        guard let actions = self.viewModel.contextAction(for: item, isLeading: false) else { return nil }
        
        let actionSelected: (ReadCollectionItemSwipeContextAction) -> Void = { [weak self] selected in
            self?.viewModel.handleContextAction(for: item, action: selected)
        }
        let contextActions = actions.map { $0.asUIContextAction(actionSelected) }
        let configure = UISwipeActionsConfiguration(actions: contextActions)
        configure.performsFirstActionWithFullSwipe = false
        return configure
    }
}

// MARK: - setup presenting

extension ReadCollectionItemsViewController: Presenting {
    
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
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 80, right: 0)
        
        self.titleHeaderView.setupStyling()
        
        self.tableView.registerCell(ReadCollcetionAttrCell.self)
        self.tableView.registerCell(ReadCollectionExpandCell.self)
        self.tableView.registerCell(ReadLinkExpandCell.self)
        self.tableView.registerCell(ReadItemShrinkCollectionCell.self)
        self.tableView.registerCell(ReadItemShrinkLinkCell.self)
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

private extension ReadCollectionItemSwipeContextAction {
    
    private var image: UIImage? {
        switch self {
        case .delete: return UIImage(systemName: "trash.fill")
        case .edit: return UIImage(systemName: "highlighter")
        case .remind(true): return UIImage(systemName: "alarm.fill")
        case .remind(false): return UIImage(systemName: "alarm")
        case .markAsRead(isRed: true): return UIImage(systemName: "checkmark.circle.fill")
        case .markAsRead(isRed: false): return UIImage(systemName: "checkmark.circle")
        case .favorite(isFavorite: true): return UIImage(systemName: "star.fill")
        case .favorite(isFavorite: false): return UIImage(systemName: "star")
        }
    }
    
    private var title: String? {
        return nil
    }
    
    private var backgroundColor: UIColor? {
        switch self {
        case .delete: return UIColor.systemRed
        case .edit: return UIColor.systemGray
        case .remind(false): return UIColor.from(hex: "#26a69a")
        case .remind(true): return UIColor.from(hex: "#00695c")
        case .markAsRead(isRed: false): return UIColor.from(hex: "#26c6da")
        case .markAsRead(isRed: true): return UIColor.from(hex: "#00838f")
        case .favorite(isFavorite: true): return UIColor.systemYellow
        case .favorite(isFavorite: false): return UIColor.systemYellow.withAlphaComponent(0.6)
        }
    }
    
    func asUIContextAction(_ handler: @escaping (Self) -> Void) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: self.title) { _, _, completionHandler in
            completionHandler(false)
            handler(self)
        }
        action.image = self.image
        action.backgroundColor = backgroundColor
        
        return action
    }
}

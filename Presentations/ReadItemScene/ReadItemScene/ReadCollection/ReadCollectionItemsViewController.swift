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

public final class ReadCollectionItemsViewController: BaseViewController, ReadCollectionScene {
    
    typealias CVM = ReadItemCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private var currentCollectionID: String? { self.viewModel.currentCollectionID }
    
    private var dataSource: DataSource!
    let viewModel: ReadCollectionItemsViewModel
    
    let titleHeaderView = ReadCollectionTtileHeaderView()
    let tableView = UITableView()
    
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
    }
    
}

// MARK: - bind

extension ReadCollectionItemsViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
                self?.bindTitleView()
            })
            .disposed(by: self.disposeBag)
        
        self.setupEditButtonIfPossible()
    }
    
    private func setupEditButtonIfPossible() {
        
        guard self.viewModel.isEditable else {
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        
        let button = UIBarButtonItem(title: "Edit".localized, image: nil, primaryAction: nil, menu: nil)
        self.navigationItem.rightBarButtonItem = button

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                // TODO: start edit mode
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
            
            case let collection as ReadCollectionCellViewModel:
                let cell: ReadCollectionExpandCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell

            case let link as ReadLinkCellViewModel:
                let cell: ReadLinkExpandCell = tableView.dequeueCell()
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

// MARK: - bind scroll and hide title

extension ReadCollectionItemsViewController {
    
    private var isTitleHaderViewShowing: Observable<Bool> {
        
        let checkScrollAmount: (CGPoint) -> Bool? = { [weak self] point in
            guard let self = self, self.titleHeaderView.frame.height > 0 else { return nil }
            return point.y <= self.titleHeaderView.frame.height
        }
        return self.tableView.rx.contentOffset
            .compactMap(checkScrollAmount)
            .distinctUntilChanged()
    }
    
    private func bindTitleView() {
        
        let selectTitle: (String, Bool) -> String? = { title, isHeaderShowing in
            return isHeaderShowing ? nil : title
        }
        Observable
            .combineLatest(self.viewModel.collectionTitle,
                           self.isTitleHaderViewShowing,
                           resultSelector: selectTitle)
            .startWith(nil)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                self?.title = title
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.collectionTitle
            .subscribe(onNext: { [weak self] title in
                self?.titleHeaderView.setupTitle(title)
            })
            .disposed(by: self.disposeBag)
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
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        
        self.titleHeaderView.setupStyling()
        
        self.tableView.registerCell(ReadCollcetionAttrCell.self)
        self.tableView.registerCell(ReadCollectionExpandCell.self)
        self.tableView.registerCell(ReadLinkExpandCell.self)
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
        case .delete: return UIImage(named: "trash.fill")
        case .edit: return UIImage(named: "highlighter")
        }
    }
    
    private var title: String? {
        return nil
    }
    
    private var backgroundColor: UIColor {
        switch self {
        case .delete: return UIColor.systemRed
        case .edit: return UIColor.systemGray
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

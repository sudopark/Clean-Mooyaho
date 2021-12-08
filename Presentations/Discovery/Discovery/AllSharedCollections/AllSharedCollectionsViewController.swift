//
//  AllSharedCollectionsViewController.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/12/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import Domain
import CommonPresenting


// MARK: - AllSharedCollectionsViewController

public final class AllSharedCollectionsViewController: BaseViewController, AllSharedCollectionsScene, ShrinkableTtileHeaderViewSupporting {
    
    typealias CVM = AllSharedCollectionCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    public let titleHeaderView: BaseTableViewHeaderView = BaseTableViewHeaderView()
    private let tableView = UITableView()
    public var titleHeaderViewRelatedScrollView: UIScrollView { self.tableView }
    
    let viewModel: AllSharedCollectionsViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: AllSharedCollectionsViewModel) {
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
    }
    
}

// MARK: - bind

extension AllSharedCollectionsViewController {
    
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
            .map { [Section(model: "shareds", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.selectCollection(sharedID: cellViewModel.shareID)
            })
            .disposed(by: self.disposeBag)
        
        let waitForDragging = self.tableView.rx.willBeginDragging.take(1)
        self.tableView.rx.scrollBottomHit(wait: waitForDragging, threshold: 20)
            .debounce(.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadMoreCollections()
            })
            .disposed(by: self.disposeBag)
        
        self.bindUpdateTitleheaderViewByScroll(with: .just("Shared collections"))
    }
    
    private func makeDataSource() -> DataSource {
        
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewModel in
            guard let self = self else { return UITableViewCell() }
            let cell: DefaultReadCollectionCell = tableView.dequeueCell()
            cell.setupCell(allCellViewModel: cellViewModel)
            cell.bindOwnerInfo(self.viewModel.sharedOwnerInfo(for: cellViewModel.ownerID))
            return cell
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - tableView delegate

extension AllSharedCollectionsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.dataSource[indexPath]
        
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, handler in
            handler(false)
            self?.viewModel.removeCollection(sharedID: item.shareID)
        }
        action.image = UIImage(systemName: "trash.fill")
        let configure = UISwipeActionsConfiguration(actions: [action])
        configure.performsFirstActionWithFullSwipe = false
        return configure
    }
}

// MARK: - setup presenting

extension AllSharedCollectionsViewController: Presenting {
    
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
        
        self.tableView.registerCell(DefaultReadCollectionCell.self)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        self.titleHeaderView.setupStyling()
    }
}

private extension DefaultReadCollectionCell {
    
    func setupCell(allCellViewModel: AllSharedCollectionCellViewModel) {
        
        self.updateOwnerView(nil)
        
        self.expandView.nameLabel.text = allCellViewModel.collectionName
        
        let validDescription = allCellViewModel.description.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.expandView.descriptionLabel.isHidden = validDescription == nil
        self.expandView.descriptionLabel.text = validDescription
            
        self.updateCategories(allCellViewModel.categories)
    }
    
    private func updateOwnerView(_ member: Member?) {
        guard let member = member else {
            self.expandView.ownerInfoView.isHidden = true
            return
        }
        self.expandView.ownerInfoView.isHidden = false
        self.expandView.ownerInfoView.updateOwner(member)
    }
    
    func bindOwnerInfo(_ source: Observable<Member>) {
        
        source.asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] member in
                self?.updateOwnerView(member)
            })
            .disposed(by: self.disposeBag)
    }
}

//
//  IntegratedSearchViewController.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting

// MARK: - IntegratedSearchViewController

public final class IntegratedSearchViewController: BaseViewController, IntegratedSearchScene {
    
    typealias CVM = SearchIndexCellViewMdoel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView()
    public let suggestSceneContainer: UIView = UIView()
    private let emptyView = EmptyResultView()
    
    let viewModel: IntegratedSearchViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: IntegratedSearchViewModel) {
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
        self.viewModel.setupSubScene()
    }
    
}

// MARK: - bind

extension IntegratedSearchViewController {
    
    private func bind() {
        
        self.viewModel.showSuggestScene
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] show in
                self?.updateSuggestSectionShowing(show: show)
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateSuggestSectionShowing(show: Bool) {
        let hide = !show
        let suggestScene = self.children.first(where: { $0 is SuggestQueryScene })
        suggestScene?.view.isHidden = hide
        self.suggestSceneContainer.isHidden = hide
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDatasource()
        
        self.viewModel.searchResultSections
            .asDriver(onErrorDriveWith: .never())
            .map { $0.map { Section(model: $0.title, items: $0.cellViewModels) } }
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.showSearchResultDetail(cellViewModel.identifier)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.resultIsEmpty
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isEmpty in
                self?.emptyView.isHidden = !isEmpty
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDatasource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { _, tableView, indexPath, cellViewModel in
            switch cellViewModel {
            case let readItem as SearchReadItemCellViewModel:
                let cell: SearchReadItemCell = tableView.dequeueCell()
                cell.setupCell(readItem)
                return cell
                
            default: return UITableViewCell()
            }
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension IntegratedSearchViewController: Presenting, UITableViewDelegate {
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view)
        
        self.view.addSubview(emptyView)
        emptyView.autoLayout.fill(self.view)
        emptyView.setupLayout()
        
        self.view.addSubview(suggestSceneContainer)
        suggestSceneContainer.autoLayout.fill(self.view)
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appSecondBackground
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.registerCell(SearchReadItemCell.self)
        
        self.emptyView.setupStyling()
        self.emptyView.isHidden = true
        self.emptyView.backgroundColor = self.uiContext.colors.appSecondBackground
    }
    
    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        guard let section = self.dataSource?.sectionModels[safe: section] else { return nil }
        let header = ReadCollectionSectionHeaderView()
        header.setupTitle(section.model)
        return header
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
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

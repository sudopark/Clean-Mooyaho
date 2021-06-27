//
//  SelectHoorayPlaceViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting


// MARK: - SelectHoorayPlaceViewController

public final class SelectHoorayPlaceViewController: BaseViewController, SelectHoorayPlaceScene {
    
    let selectView = SelectHoorayView()
    let viewModel: SelectHoorayPlaceViewModel
    
    private typealias CellViewModel = SuggestPlaceCellViewModel
    private typealias Section = SectionModel<String, CellViewModel>
    private typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private var dataSource: DataSource!
    
    public init(viewModel: SelectHoorayPlaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
        LeakDetector.instance.expectDeallocate(object: self.selectView)
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

extension SelectHoorayPlaceViewController {
    
    private func bind() {
        
        self.viewModel.isFinishInputEnabled
            .asDriver(onErrorDriveWith: .never())
            .drive(self.selectView.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.selectView.headerView.searchBar.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.suggestPlace(by: text)
            })
            .disposed(by: self.disposeBag)
        
        self.selectView.headerView.refreshButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshUserLocation()
            })
            .disposed(by: self.disposeBag)
        
        self.selectView.headerView.addPlaceButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.registerNewPlace()
            })
            .disposed(by: self.disposeBag)
        
        self.selectView.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelectPlace()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindMapView()
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindMapView() {
        self.viewModel.currentUserLocation
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] location in
                // update user location on map -> move camera
            })
            .disposed(by: self.disposeBag)

        self.viewModel.cellViewModels
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] cellViewModels in
                // toggle icons and selected icon on map
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        
        typealias TableViewDataSource = TableViewSectionedDataSource<Section>
        let configureCell: (TableViewDataSource, UITableView, IndexPath, CellViewModel) -> UITableViewCell
        configureCell = { _, tableview, indexPath, cellViewModel in
            let cell: SelectHooraySuggestPlaceCell = tableview.dequeueCell()
            cell.setupCell(cellViewModel)
            return cell
        }
        return .init(configureCell: configureCell)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map{ [Section(model: "suggests", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.selectView.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.selectView.tableView.rx.modelSelected(CellViewModel.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.toggleUpdateSelected(cellViewModel.placeID)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension SelectHoorayPlaceViewController: Presenting, UITableViewDelegate {
    
    public func setupLayout() {
        
        self.view.addSubview(selectView)
        selectView.autoLayout.fill(self.view)
        self.selectView.setupLayout()
    }
    
    public func setupStyling() {
        self.selectView.setupStyling()
        self.selectView.tableView.delegate = self
    }
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueCell()
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

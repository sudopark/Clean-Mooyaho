//
//  SearchNewPlaceViewController.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting


// MARK: - SearchNewPlaceViewController

public final class SearchNewPlaceViewController: BaseViewController, SearchNewPlaceScene {
    
    typealias CellType = SearchingNewPlaceCellViewModelType
    typealias Section = SectionModel<String, CellType>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    let searchBar = SearchBar()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let confirmButton = LoadingButton()
    
    let viewModel: SearchNewPlaceViewModel
    var dataSource: DataSource!
    
    private let cellActionSubject = PublishSubject<SearchinNewPlaceCellAction>()
    
    public init(viewModel: SearchNewPlaceViewModel) {
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

extension SearchNewPlaceViewController {
    
    private func bind() {
        
        self.searchBar.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.search(text)
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { _ in
                self.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.searchBar.clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.searchBar.inputField.text = nil
                self?.viewModel.finishSearch()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isPlaceSelectConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] enable in
                self?.confirmButton.isHidden = enable == false
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isRegistering
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isRegistering in
                self?.confirmButton.updateIsLoading(isRegistering)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - handle tableview

extension SearchNewPlaceViewController: UITableViewDelegate {
    
    private func makeDataSource() -> DataSource {
        return DataSource { [weak self] _, tableView, indexPath, cellViewModel in
            
            switch cellViewModel {
            case is SeerchingNewPlaceAddNewCellViewModel:
                let cell: SearchNewPlaceAddCell = tableView.dequeueCell()
                return cell
            
            case let cvm as SearchinNewPlaceCellViewModel:
                let cell: SearchNewPlaceCell = tableView.dequeueCell()
                cell.cellActionSubject = self?.cellActionSubject
                cell.setupCell(cvm)
                return cell
            
            default: return UITableViewCell()
            }
        }
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map{ [Section(model: "search result", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CellType.self)
            .subscribe(onNext: { [weak self] celltype in
                self?.view.endEditing(true)
                switch celltype {
                case is SeerchingNewPlaceAddNewCellViewModel:
                    self?.viewModel.requestManualRegisterPlace()
                    
                case let cvm as SearchinNewPlaceCellViewModel:
                    self?.viewModel.toggleSelectPlace(cvm.placeID)
                    
                default: break
                }
            })
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.scrollBottomHit(wait: .just())
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadMore()
            })
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.contentOffset
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
        
        self.cellActionSubject
            .subscribe(onNext: { [weak self] action in
                guard case let .showDetail(placeID) = action else { return }
                self?.viewModel.showPlaceDetail(placeID)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: SearchNewPlaceSectionHeaderView = tableView.dequeueHeaderFooterView()
        if let placeMark = self.viewModel.currentPlaceMark {
            headerView.titleLabel.text = "Current place: \(placeMark)"
        } else {
            headerView.titleLabel.text = "Place search result".localized
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView,
                          willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = self.uiContext.colors.appBackground
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollVelocity = scrollView.panGestureRecognizer.velocity(in: self.view)
        if scrollVelocity.y > 2000 {
            self.view.endEditing(true)
        }
    }
}

// MARK: - setup presenting

extension SearchNewPlaceViewController: Presenting {
    
    public func setupLayout() {
        self.view.addSubview(searchBar)
        searchBar.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 20)
        }
        searchBar.setupLayout()
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor,
                                         constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        confirmButton.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.searchBar.setupStyling()
        self.searchBar.inputField.placeholder = "Enter a place title..."
        
        self.tableView.registerHeaderFooter(SearchNewPlaceSectionHeaderView.self)
        self.tableView.registerCell(SearchNewPlaceAddCell.self)
        self.tableView.registerCell(SearchNewPlaceCell.self)
        self.tableView.backgroundColor = self.uiContext.colors.appBackground
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 76
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        self.confirmButton.layer.cornerRadius = 5
        self.confirmButton.clipsToBounds = true
        self.confirmButton.backgroundColor = UIColor.systemBlue
        self.confirmButton.title = "Confirm"
    }
}

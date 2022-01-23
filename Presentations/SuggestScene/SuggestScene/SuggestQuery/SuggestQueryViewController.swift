//
//  SuggestQueryViewController.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - SuggestQueryViewController

public final class SuggestQueryViewController: BaseViewController, SuggestQueryScene {
    
    typealias CVM = SuggestQueryCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView()
    private let emptyView = EmptyResultView()
    
    let viewModel: SuggestQueryViewModel
    private var dataSource: DataSource!
    private let removeQuerySubject = PublishSubject<String>()
    
    public init(viewModel: SuggestQueryViewModel) {
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

extension SuggestQueryViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.resultIsEmpty
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isEmpy in
                self?.emptyView.isHidden = isEmpy == false
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map { [Section(model: "queries", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                // TODO: 선택했을때 입력포커스 지워야함
                self?.viewModel.selectQuery(cellViewModel.queryText)
            })
            .disposed(by: self.disposeBag)
        
        self.removeQuerySubject
            .subscribe(onNext: { [weak self] query in
                self?.viewModel.removeLatestSearchQuery(query)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewModel in
            let cell: SuggestQueryCell = tableView.dequeueCell()
            cell.removeQuerySubject = self?.removeQuerySubject
            cell.setupCell(cellViewModel)
            return cell
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension SuggestQueryViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view)
        
        self.view.addSubview(emptyView)
        emptyView.autoLayout.fill(self.view)
        emptyView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appSecondBackground
        
        self.tableView.registerCell(SuggestQueryCell.self)
        self.tableView.backgroundColor = .clear
        
        emptyView.setupStyling()
        emptyView.isHidden = true
    }
}



// MNARK: - cell and subview

final class SuggestQueryCell: BaseTableViewCell, Presenting {
    
    let stackView = UIStackView()
    let queryLabel = UILabel()
    let timeLabel = UILabel()
    let closeButton = UIButton()
    private var stackViewTrailing: NSLayoutConstraint!
    
    weak var removeQuerySubject: PublishSubject<String>?
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: SuggestQueryCellViewModel) {
        self.updateCloseAread(show: cellViewModel.isLatestSearched)
        self.queryLabel.text = cellViewModel.queryText
        self.updateTimeLabel(cellViewModel.latestSearchText)
        cellViewModel.isLatestSearched.then {
            self.bindRemove(with: cellViewModel.queryText)
        }
    }
    
    private func bindRemove(with query: String) {
        self.closeButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.removeQuerySubject?.onNext(query)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateCloseAread(show: Bool) {
        let trailingForHide: CGFloat = -16
        let trailingForShow: CGFloat = -12-25-8
        self.stackViewTrailing.constant = show ? trailingForShow : trailingForHide
        self.closeButton.isHidden = show == false
    }
    
    private func updateTimeLabel(_ value: String?) {
        let validText = value?.emptyAsNil()
        self.timeLabel.isHidden = validText == nil
        self.timeLabel.text = validText
    }
}

extension SuggestQueryCell {
    
    func setupLayout() {
        
        self.contentView.addSubview(stackView)
        stackView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -14)
        }
        self.stackViewTrailing = stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(queryLabel)
        stackView.addArrangedSubview(timeLabel)
        
        self.contentView.addSubview(closeButton)
        closeButton.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.widthAnchor.constraint(equalToConstant: 25)
            $0.heightAnchor.constraint(equalToConstant: 25)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = .clear
        
        _ = self.queryLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.numberOfLines .~ 1
        
        _ = self.timeLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.numberOfLines .~ 1
            |> \.isHidden .~ true
        
        self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        self.closeButton.contentEdgeInsets = .init(top: 6.5, left: 6.5, bottom: 6.5, right: 6.5)
        self.closeButton.tintColor = self.uiContext.colors.descriptionText
        self.closeButton.isHidden = true
    }
}


final class EmptyResultView: BaseUIView, Presenting {
    
    let titleLabel = UILabel()
    
    func setupLayout() {
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: -40)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor, constant: 25)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -25)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.appSecondBackground
        
        _ = self.titleLabel
            |> self.uiContext.decorating.listSectionTitle(_:)
            |> \.numberOfLines .~ 0
            |> \.text .~ pure("No result found".localized)
    }
}

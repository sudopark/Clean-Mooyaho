//
//  EditReadPriorityViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - EditReadPriorityViewController

final class ReadPriorityCell: BaseTableViewCell, Presenting {
    
    let explainLabel = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: ReadPriorityCellViewMdoel) {
        
        self.explainLabel.text = cellViewModel.descriptionText
        self.accessoryType = cellViewModel.isSelected ? .checkmark : .none
    }
    
    func setupLayout() {
        self.contentView.addSubview(explainLabel)
        explainLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
    }
    
    func setupStyling() {
        
        self.explainLabel.font = self.uiContext.fonts.get(15, weight: .regular)
        self.explainLabel.textColor = self.uiContext.colors.text
        self.explainLabel.numberOfLines = 1
    }
}

public final class EditReadPriorityViewController<ViewModel: EditReadPriorityViewModel>
    : BaseViewController, EditReadPriorityScene, BottomSlideViewSupporatble {
    
    private typealias CVM = ReadPriorityCellViewMdoel
    private typealias Section = SectionModel<String, CVM>
    private typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let confirmButton = ConfirmButton()
    
    let viewModel: ViewModel
    private var dataSource: DataSource!
    private let tableViewDelegate = TableViewDelegate()
    
    public init(viewModel: ViewModel) {
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
    
    public func requestCloseScene() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - bind

extension EditReadPriorityViewController {
    
    private func bind() {
        
        self.viewModel.showPriorities()
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.requestCloseScene()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map { [Section(model: "priorities", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] model in
                self?.viewModel.selectPriority(model.rawValue)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        
        return .init { _, tableView, indexPath, cellViewModel in
            let cell: ReadPriorityCell = tableView.dequeueCell()
            cell.setupCell(cellViewModel)
            return cell
        }
    }
}

// MARK: - setup presenting

extension EditReadPriorityViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        self.bottomSlideMenuView.containerView.addSubview(tableView)
        tableView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 360)
        }
        
        self.bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        self.bottomSlideMenuView.containerView.backgroundColor = UIColor.systemGroupedBackground
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Set a priority"
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 42.5
        self.tableView.registerCell(ReadPriorityCell.self)
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 30, right: 0)
        self.tableView.delegate = self.tableViewDelegate
        
        self.confirmButton.setupStyling()
    }
}


private class TableViewDelegate: NSObject, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

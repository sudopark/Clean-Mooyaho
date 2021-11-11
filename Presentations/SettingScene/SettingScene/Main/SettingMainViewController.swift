//
//  SettingMainViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/11/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - SettingMainViewController

public final class SettingMainViewController: BaseViewController, SettingMainScene {
    
    typealias CellViewModel = SettingItemCellViewModel
    typealias Section = SectionModel<String, CellViewModel>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    let viewModel: SettingMainViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: SettingMainViewModel) {
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

extension SettingMainViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
    }
 
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.sections
            .map { $0.map { Section(model: $0.title, items: $0.cellViewModels) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CellViewModel.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.selectItem(cellViewModel.itemID)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { _, tableView, indexPath, cellViewMdoel in
            let cell: SettingItemCell = tableView.dequeueCell()
            cell.setupCell(cellViewMdoel)
            return cell
        }
        
        let configureSection: DataSource.TitleForHeaderInSection = { source, index in
            let section = source[index]
            return section.model
        }
        
        return DataSource(configureCell: configureCell, titleForHeaderInSection: configureSection)
    }
}

// MARK: - setup presenting

extension SettingMainViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 44)
        }
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        }
    }
    
    public func setupStyling() {
        
        _ = self.titleLabel
            |> self.uiContext.decorating.title(_:)
            |> \.backgroundColor .~ pure(self.uiContext.colors.appBackground)
            |> \.text .~ pure("Setting".localized)
            |> \.textAlignment .~ .center
            |> \.font .~ self.uiContext.fonts.get(17, weight: .medium)
        
        tableView.registerCell(SettingItemCell.self)
        tableView.rowHeight = 60
    }
}


final class SettingItemCell: BaseTableViewCell {
    
    let titleLabel = UILabel()
    let accentValueLabel = UILabel()
    private var titleLabelTrailing: NSLayoutConstraint!
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: SettingItemCellViewModel) {
        
        self.titleLabel.text = cellViewModel.title
        self.updateAccessoryView(cellViewModel.accessory)
    }
    
    private func updateAccessoryView(_ accessory: SettingItemCellViewModel.Accessory) {
        switch accessory {
        case .disclosure:
            self.accessoryType = .disclosureIndicator
            self.accentValueLabel.isHidden = true
            self.titleLabelTrailing.constant = 0
            
        case let .accentValue(value):
            self.accessoryType = .none
            self.titleLabelTrailing.constant = -8
            self.accentValueLabel.text = value
            self.accentValueLabel.isHidden = false
        }
    }
}

extension SettingItemCell: Presenting {
    
    func setupLayout() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.contentView.addSubview(accentValueLabel)
        accentValueLabel.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        self.titleLabelTrailing = titleLabel.trailingAnchor
            .constraint(lessThanOrEqualTo: accentValueLabel.leadingAnchor)
        accentValueLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setupStyling() {
        
        _ = self.titleLabel
            |> \.textColor .~ self.uiContext.colors.title.withAlphaComponent(0.8)
            |> \.font .~ self.uiContext.fonts.get(15, weight: .regular)
            |> \.numberOfLines .~ 1
        
        _ = self.accentValueLabel
            |> self.uiContext.decorating.listItemAccentText(_:)
            |> \.font .~ self.uiContext.fonts.get(15, weight: .regular)
            |> \.numberOfLines .~ 1
            |> \.isHidden .~ true
    }
}

//
//  ManageAccountViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - ManageAccountViewController

public final class ManageAccountViewController: BaseViewController, ManageAccountScene {
    
    typealias CVM = ManageAccountCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    let viewModel: ManageAccountViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: ManageAccountViewModel) {
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

extension ManageAccountViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)

        self.viewModel.isProcessing
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isProcessing in
                self?.view.isUserInteractionEnabled = isProcessing == false
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        self.dataSource = self.makeDatasource()
        
        self.viewModel.cellViewModels
            .map { $0.enumerated().map { Section(model: "section:\($0.offset)", items: $0.element) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                switch cellViewModel {
                case .signout:
                    self?.viewModel.signout()
                    
                case .withdrawal:
                    self?.viewModel.withdrawal()
                    
                default: break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDatasource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { _, tableView, indexPath, cellViewModel in
            switch cellViewModel {
            case .signout, .withdrawal:
                let cell: SettingItemCell = tableView.dequeueCell()
                cell.setupCell(cellViewModel)
                return cell
                
            case .withdrawalDescription:
                let cell: ManageAccountDescriptionCell = tableView.dequeueCell()
                return cell
            }
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension ManageAccountViewController: Presenting, UITableViewDelegate {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.title = "Manage Account".localized
        
        tableView.registerCell(SettingItemCell.self)
        tableView.registerCell(ManageAccountDescriptionCell.self)
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = self.dataSource[indexPath]
        return cellViewModel == .withdrawalDescription ? UITableView.automaticDimension : 60
    }
}


// description cell

final class ManageAccountDescriptionCell: BaseTableViewCell, Presenting {
    
    let descriptionLabel = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
        }
    }
    
    func setupStyling() {
        self.backgroundColor = .clear

        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemSubDescription(_:)
            |> \.text .~ pure("When you delete your account, all of your data is immediately deleted and cannot be restored.".localized)
    }
}

private extension SettingItemCell {
    
    func setupCell(_ cellViewModel: ManageAccountCellViewModel) {
        switch cellViewModel {
        case .signout:
            self.titleLabel.text = "Signout".localized
            self.titleLabel.textColor = self.uiContext.colors.text
        case .withdrawal:
            self.titleLabel.text = "Delete account".localized
            self.titleLabel.textColor = UIColor.systemRed
        default:
            break
        }
    }
}

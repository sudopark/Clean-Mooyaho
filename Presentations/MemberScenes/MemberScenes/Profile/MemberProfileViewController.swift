//
//  MemberProfileViewController.swift
//  MemberScenes
//
//  Created sudo.park on 2021/12/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - MemberProfileViewController

public final class MemberProfileViewController: BaseViewController, MemberProfileScene {
    
    typealias CVM = MemberCellViewModelTyoe
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView()
    
    let viewModel: MemberProfileViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: MemberProfileViewModel) {
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
        self.viewModel.refresh()
    }
    
}

// MARK: - bind

extension MemberProfileViewController {
    
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
            .map { $0.map { Section(model: $0.sectionName, items: $0.cellViewModels) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { _, tableView, indexPath, cellViewModel in
            switch cellViewModel {
            case let info as MemberInfoCellViewMdoel:
                let cell: MemberProfileInfoCell = tableView.dequeueCell()
                cell.setupCell(info)
                return cell
                
            default: return UITableViewCell()
            }
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension MemberProfileViewController: Presenting {
    
    
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
        self.title = "Member profile".localized
        
        self.tableView.registerCell(MemberProfileInfoCell.self)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        self.tableView.separatorStyle = .none
    }
}


final class MemberProfileInfoCell: BaseTableViewCell, Presenting {
    
    let borderView = UIView()
    let thumbnailImageView = IntegratedImageView()
    let nameLabel = UILabel()
    let introValueLabel = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ info: MemberInfoCellViewMdoel) {
        self.thumbnailImageView.cancelSetupImage()
        self.thumbnailImageView.setupImage(using: info.thumbnail, resize: .init(width: 100, height: 100))
        self.nameLabel.text = info.displayName
        self.introValueLabel.text = info.intro
    }
}

extension MemberProfileInfoCell {
    
    func setupLayout() {
        
        self.addSubview(borderView)
        borderView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 100)
            $0.heightAnchor.constraint(equalToConstant: 100)
        }
        self.borderView.addSubview(thumbnailImageView)
        self.thumbnailImageView.autoLayout.fill(borderView, edges: .init(top: 1, left: 1, bottom: 1, right: 1))
        self.thumbnailImageView.setupLayout()
        
        self.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        self.nameLabel.setContentHuggingPriority(.required, for: .vertical)
        
        self.addSubview(introValueLabel)
        introValueLabel.autoLayout.active(with: self.nameLabel) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -16)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        _ = self.nameLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.numberOfLines .~ 1
            |> \.text .~ pure("Unnamed member".localized)
        
        _ = self.introValueLabel
            |> self.uiContext.decorating.listItemDescription
            |> \.numberOfLines .~ 0
        
        self.thumbnailImageView.setupStyling()
        self.thumbnailImageView.backgroundColor = self.uiContext.colors.appBackground
        self.thumbnailImageView.layer.cornerRadius = 49
        self.thumbnailImageView.clipsToBounds = true
        
        self.borderView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.borderView.layer.cornerRadius = 50
        self.borderView.clipsToBounds = true
    }
}

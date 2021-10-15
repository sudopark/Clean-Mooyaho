//
//  EditItemsCustomOrderViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - EditItemOrderCellViewModel

class EditItemOrderCell: BaseTableViewCell, Presenting {
    
    let shrinkView = ReadItemShrinkContentView()
    let underLineView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(shrinkView)
        shrinkView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        shrinkView.setupLayout()
        
        self.contentView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
    }
    
    func setupStyling() {
        
        self.shrinkView.setupStyling()
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
    }
}

final class EditItemOrderCollectionCell: EditItemOrderCell {
    
    func setupCell(_ cellViewModel: EditCollectionItemOrderCellViewModel) {
        
        self.shrinkView.nameLabel.text = cellViewModel.name
        
        let validDescription = cellViewModel.description.flatMap{ $0.isNotEmpty ? $0 : nil }
        self.shrinkView.descriptionLabel.isHidden = validDescription == nil
        self.shrinkView.descriptionLabel.text = validDescription
    }
    
    override func setupStyling() {
        super.setupStyling()
        self.shrinkView.iconImageView.image = UIImage(named: "folder")
        self.shrinkView.iconImageView.tintColor = self.uiContext.colors.secondaryTitle
    }
}

final class EditItemOrderLinkCell: EditItemOrderCell {
    
    func setupCell(_ cellViewModel: EditLinkItemOrderCellViewModel) {
        self.updateTitle(cellViewModel.customName)
        
        self.shrinkView.addressLabel.text = cellViewModel.address
    }
    
    func bindPreview(_ source: Observable<LinkPreview>, customTitle: String?) {
        
        source
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] preview in
                guard let self = self else { return }
                (customTitle?.isEmpty ?? true).then <| { self.updateTitle(preview.title) }
                self.updateDescription(preview.description)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateTitle(_ title: String?) {
        let title = title.flatMap{ $0.isNotEmpty ? $0 : nil } ?? "Fail to load preview".localized
        self.shrinkView.nameLabel.text = title
    }
    
    private func updateDescription(_ description: String?) {
        let description = description.flatMap { $0.isNotEmpty ? $0 : nil }
        self.shrinkView.descriptionLabel.isHidden = description == nil
        self.shrinkView.descriptionLabel.text = description
    }
    
    override func setupStyling() {
        super.setupStyling()
        self.shrinkView.iconImageView.image = UIImage(named: "doc.text")
        self.shrinkView.iconImageView.tintColor = self.uiContext.colors.secondaryTitle
    }
}


// MARK: - EditItemsCustomOrderViewController

public final class EditItemsCustomOrderViewController: BaseViewController, EditItemsCustomOrderScene {
    
    typealias CVM = ReadItemCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let confirmButton = ConfirmButton()
    
    let viewModel: EditItemsCustomOrderViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: EditItemsCustomOrderViewModel) {
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
        self.viewModel.loadCollectionItemsWithCustomOrder()
    }
}

// MARK: - bind

extension EditItemsCustomOrderViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSave()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.sections
            .map { $0.map { Section(model: $0.title, items: $0.cellViewModels) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemMoved
            .subscribe(onNext: { [weak self] from, to in
                self?.viewModel.itemMoved(from: from, to: to)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewModel in
            guard let self = self else { return UITableViewCell() }
            switch cellViewModel {
            case let collection as EditCollectionItemOrderCellViewModel:
                let cell: EditItemOrderCollectionCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell
                
            case let link as EditLinkItemOrderCellViewModel:
                let cell: EditItemOrderLinkCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.readLinkPreview(for: link.address), customTitle: link.customName)
                return cell
            default: return UITableViewCell()
            }
        }
        let headerTitle: DataSource.TitleForHeaderInSection = { [weak self] _, section in
            guard let sectionTitle = self?.dataSource[section].model else { return nil }
            return sectionTitle
            
        }
        let canMove: DataSource.CanMoveRowAtIndexPath = { _, indexPath in
            return true
        }
        
        return .init(configureCell: configureCell, titleForHeaderInSection: headerTitle, canMoveRowAtIndexPath: canMove)
    }
}


// MARK: - setup presenting

extension EditItemsCustomOrderViewController: Presenting, UITableViewDelegate {
    
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        }
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Change items order"
        
        self.tableView.registerCell(EditItemOrderCollectionCell.self)
        self.tableView.registerCell(EditItemOrderLinkCell.self)
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        self.tableView.isEditing = true
        self.tableView.separatorStyle = .none
        
        self.confirmButton.setupStyling()
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView,
                          editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    public func tableView(_ tableView: UITableView,
                          targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                          toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let isSameSection = sourceIndexPath.section == proposedDestinationIndexPath.section
        return isSameSection ? proposedDestinationIndexPath : sourceIndexPath
    }
}

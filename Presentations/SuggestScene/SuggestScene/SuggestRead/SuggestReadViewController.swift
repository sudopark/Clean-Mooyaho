//
//  SuggestReadViewController.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting

typealias ReadCollectionCell = DefaultReadCollectionCell
typealias ReadLinkCell = DefaultReadLinkCell

// MARK: - SuggestReadViewController

public final class SuggestReadViewController: BaseViewController, SuggestReadScene {
    
    typealias CVM = ReadItemCellViewModel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    let viewModel: SuggestReadViewModel
    private var dataSource: DataSource!
    
    public init(viewModel: SuggestReadViewModel) {
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

extension SuggestReadViewController {
    
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
            .map { $0.map { Section(model: $0.type.rawValue, items: $0.cellViewModels) } }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewMdoel in
                switch cellViewMdoel {
                case let collection as ReadCollectionCellViewModel:
                    self?.viewModel.selectCollection(collection.uid)
                    
                case let link as ReadLinkCellViewModel:
                    self?.viewModel.selectReadLink(link.uid)
                    
                default: return
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewModel in
            guard let self = self else { return UITableViewCell() }
            switch cellViewModel {
            case let collection as ReadCollectionCellViewModel:
                let cell: ReadCollectionCell = tableView.dequeueCell()
                cell.setupCell(collection)
                return cell
                
            case let link as ReadLinkCellViewModel:
                let cell: ReadLinkCell = tableView.dequeueCell()
                cell.setupCell(link)
                cell.bindPreview(self.viewModel.readLinkPreview(for: link.uid),
                                 customTitle: link.customName)
                return cell
                
            default: return UITableViewCell()
            }
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension SuggestReadViewController: Presenting, UITableViewDelegate {
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
        }
    }
    
    public func setupStyling() {
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        
        self.tableView.registerCell(ReadCollectionCell.self)
        self.tableView.registerCell(ReadLinkCell.self)
    }
    
    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        guard let section = self.dataSource?.sectionModels[safe: section],
              let sectionType = SuggestReadSection.SuggestType(rawValue: section.model) else {
            return nil
        }
        return sectionType.makeHeaderView()
    }
    
    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}


// MARK: - SuggestReadSectionHeaderView

final class SuggestReadSectionHeaderView: ReadCollectionSectionHeaderView {
    
    let arrowImageView = UIImageView()
    
    override func setupLayout() {
        super.setupLayout()
        self.contentView.addSubview(arrowImageView)
        arrowImageView.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.widthAnchor.constraint(equalToConstant: 8)
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
    }
    
    override func setupStyling() {
        super.setupStyling()
        self.arrowImageView.image = UIImage(systemName: "chevron.right")
        self.arrowImageView.contentMode = .scaleAspectFit
        self.arrowImageView.tintColor = self.uiContext.colors.buttonBlue
    }
}

private extension SuggestReadSection.SuggestType {
    
    private var title: String {
        switch self {
        case .todoRead: return "📚 To read".localized
        case .favotire: return "👍 My Favorites".localized
        case .continueRead: return "🏃‍♂️ Continue red".localized
        }
    }
    
    func makeHeaderView() -> SuggestReadSectionHeaderView {
        let header = SuggestReadSectionHeaderView()
        header.setupTitle(self.title)
        return header
    }
}

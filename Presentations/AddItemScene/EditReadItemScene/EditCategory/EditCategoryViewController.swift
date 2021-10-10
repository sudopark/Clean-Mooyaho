//
//  EditCategoryViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting


// MARK: - EditCategoryViewController

public final class EditCategoryViewController: BaseViewController, EditCategoryScene {
    
    typealias SuggestCVM = SuggestingCategoryCellViewModelType
    typealias SuggestSection = SectionModel<String, SuggestCVM>
    typealias SuggestDataSource = RxTableViewSectionedReloadDataSource<SuggestSection>
    
    typealias SelectCVM = SuggestingCategoryCellViewModel
    typealias SelectSection = SectionModel<String, SelectCVM>
    typealias SelectDataSource = RxCollectionViewSectionedReloadDataSource<SelectSection>
     
    private let titleLabel = UILabel()
    private let inputField = SingleLineInputView()
    private var selectedCollectionView: UICollectionView!
    private let tableView = UITableView()
    private let confirmButton = ConfirmButton()
    private var tableViewTopConstraint: NSLayoutConstraint!
    
    let viewModel: EditCategoryViewModel
    private var suggestDataSource: SuggestDataSource!
    private var selectDataSource: SelectDataSource!
    private let createCategorySubject = PublishSubject<SuggestMakeNewCategoryCellViewMdoel>()
    
    public init(viewModel: EditCategoryViewModel) {
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
        self.viewModel.prepareCategoryList()
    }
    
}

// MARK: - bind

extension EditCategoryViewController {
    
    private func bind() {
    
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindCollectionView()
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.confirmActionTitleBySelectedCount
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.confirmButton.setTitle(title, for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.clearText
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.inputField.clearInput()
            })
            .disposed(by: self.disposeBag)
        
        self.inputField.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.suggest(text)
            })
            .disposed(by: self.disposeBag)
        
        self.inputField.rx.clear
            .subscribe(onNext: { [weak self] in
                self?.inputField.clearInput()
                self?.viewModel.suggest("")
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - bind collectionView

extension EditCategoryViewController {
    
    private func bindCollectionView() {
     
        self.selectDataSource = self.makeCollectionViewDataSource()
        
        self.viewModel.selectedCellViewModels
            .map { [SelectSection(model: "select", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .do(onNext: { [weak self] sections in
                self?.updateSelectedSectionVisibility(sections.first?.items.isNotEmpty == true)
            })
            .drive(self.selectedCollectionView.rx.items(dataSource: self.selectDataSource))
            .disposed(by: self.disposeBag)
        
        self.selectedCollectionView.rx.modelSelected(SelectCVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.deselect(cellViewModel.uid)
            })
            .disposed(by: self.disposeBag)
                
        self.viewModel.scrollToLastSelectionSection
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                self.selectedCollectionView
                    .scrollToItem(at: IndexPath(row: index, section: 0), at: .right, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeCollectionViewDataSource() -> SelectDataSource {
        return .init { _, collectionView, indexPath, cellViewModel in
            let cell: SelectedCategoryCell = collectionView.dequeueCell(for: indexPath)
            cell.setupCell(cellViewModel)
            return cell
        }
    }
    
    private func updateSelectedSectionVisibility(_ show: Bool) {
        self.selectedCollectionView.isHidden = show == false
        self.tableViewTopConstraint.constant = show ? 52 : 12
    }
}


// MARK: - bind tableview

extension EditCategoryViewController {
    
    private func bindTableView() {
        
        self.suggestDataSource = self.makeTableViewDataSource()
        
        self.viewModel.cellViewModels
            .map { [SuggestSection(model: "suggest", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.suggestDataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(SuggestCVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                switch cellViewModel {
                case is SuggestMakeNewCategoryCellViewMdoel:
                    self?.viewModel.changeColor()
                    
                case let suggest as SuggestingCategoryCellViewModel:
                    self?.viewModel.select(suggest.uid)
                    
                default: break
                }
            })
            .disposed(by: self.disposeBag)
        
        self.createCategorySubject
            .subscribe(onNext: { [weak self] model in
                self?.viewModel.makeNew(model)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeTableViewDataSource() -> SuggestDataSource {
        let configureCell: SuggestDataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewMdoel in
            switch cellViewMdoel {
            case let makeNew as SuggestMakeNewCategoryCellViewMdoel:
                let cell: SuggestMakeNewCategoryCell = tableView.dequeueCell()
                cell.createSubject = self?.createCategorySubject
                cell.setupCell(makeNew)
                return cell
                
            case let sugest as SuggestingCategoryCellViewModel:
                let cell: SuggestingCategoryCell = tableView.dequeueCell()
                cell.setupCell(sugest)
                return cell
                
            default: return UITableViewCell()
            }
        }
        let configureTitle: SuggestDataSource.TitleForHeaderInSection = { _, _ in
            return "Suggesting categories"
        }
        return .init(configureCell: configureCell, titleForHeaderInSection: configureTitle)
    }
}


// MARK: - setup presenting

extension EditCategoryViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        }
        
        self.view.addSubview(inputField)
        inputField.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32)
        }
        inputField.setupLayout()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.selectedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view.addSubview(selectedCollectionView)
        selectedCollectionView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor, constant: -15)
            $0.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 12)
            $0.heightAnchor.constraint(equalToConstant: 32)
        }
        
        self.view.addSubview(tableView)
        tableViewTopConstraint = tableView.autoLayout.make(with: inputField) {
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor, constant: 12)
        }.first
        tableViewTopConstraint.isActive = true
        tableView.autoLayout.active(with: self.view) {
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
            |> \.text .~ "Choose a category"
        
        self.inputField.setupStyling()
        self.inputField.backgroundColor = .clear
        self.inputField.placeHolderLabel.text = "Enter a name"
        
        self.selectedCollectionView.registerCell(SelectedCategoryCell.self)
        self.selectedCollectionView.delegate = self
        self.selectedCollectionView.isHidden = true
        
        self.tableView.registerCell(SuggestingCategoryCell.self)
        self.tableView.registerCell(SuggestMakeNewCategoryCell.self)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        self.confirmButton.setupStyling()
    }
}


// MARK: - collectionView delegate

extension EditCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = self.selectDataSource.sectionModels.first?.items[safe: indexPath.row] else {
            return .zero
        }
        let font = self.uiContext.fonts.get(14, weight: .regular)
        return SelectedCategoryCell.Metrics.expectCellSize(for: item.name, font: font)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}


// MARK: - tableview delegate

extension EditCategoryViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

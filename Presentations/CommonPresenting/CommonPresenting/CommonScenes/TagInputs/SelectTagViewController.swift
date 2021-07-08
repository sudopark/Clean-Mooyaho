//
//  SelectTagViewController.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - SelectTagViewController

public final class SelectTagViewController: BaseViewController, SelectTagScene {
    
    let bottomSlideMenuView = BaseBottomSlideMenuView()
    let titleLabel = UILabel()
    let wordTokensView = WordTokensView()
    let confirmButton = ConfirmButton(type: .system)
    
    let viewModel: SelectTagViewModel
    
    public init(viewModel: SelectTagViewModel) {
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

extension SelectTagViewController {
    
    private func bind() {
        
        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindtags()
            })
            .disposed(by: self.disposeBag)
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.closeScene()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindtags() {
        
        self.viewModel.cellViewModels
            .map{ $0.asWordTokens() }
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] tokens in
                self?.wordTokensView.updateTokens(tokens)
            })
            .disposed(by: self.disposeBag)
        
        self.wordTokensView.collectionView.rx.itemSelected
            .withLatestFrom(self.viewModel.cellViewModels, resultSelector: { $1[$0.row] })
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.toggleSelect(cellViewModel)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension SelectTagViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        bottomSlideMenuView.containerView.addSubview(wordTokensView)
        wordTokensView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
            $0.heightAnchor.constraint(equalToConstant: 150)
        }
        wordTokensView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        confirmButton.autoLayout.active {
            $0.topAnchor.constraint(equalTo: wordTokensView.bottomAnchor, constant: 30)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        self.uiContext.deco.title(self.titleLabel)
        self.titleLabel.text = "Select tags"
        
        self.wordTokensView.setupStyling()
        
        self.confirmButton.setupStyling()
    }
}


private extension Array where Element == TagCellViewModel {
    
    func asWordTokens() -> [WordToken] {
        
        return self.map { cellViewModel in
            
            return .init(word: cellViewModel.keyword,
                         color: .systemBlue,
                         isHighlighted: cellViewModel.isSelected)
        }
    }
}

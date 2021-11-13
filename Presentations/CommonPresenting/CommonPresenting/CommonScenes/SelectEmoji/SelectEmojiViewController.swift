//
//  SelectEmojiViewController.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/11/13.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - SelectEmojiViewController

public final class SelectEmojiViewController: BaseViewController, SelectEmojiScene {
    
    private let fakeInputView = UITextField()
    private let emojiListView = EmojiListView()
    public weak var listener: SelectEmojiSceneListenable?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {

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

extension SelectEmojiViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindEmojiView()
            })
            .disposed(by: self.disposeBag)
        
        self.view.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                self?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindEmojiView() {
        
        self.emojiListView.selectedEmoji
            .subscribe(onNext: { [weak self] emoji in
                self?.handleEmojiSelected(emoji)
            })
            .disposed(by: self.disposeBag)
        
        self.fakeInputView.inputView = emojiListView
        self.fakeInputView.becomeFirstResponder()
    }
    
    private func handleEmojiSelected(_ value: String) {
        
        self.dismiss(animated: true) { [weak self] in
            self?.listener?.selectEmoji(didSelect: value)
        }
    }
}

// MARK: - setup presenting

extension SelectEmojiViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(fakeInputView)
        fakeInputView.autoLayout.active(with: self.view) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.widthAnchor.constraint(equalToConstant: 10)
            $0.heightAnchor.constraint(equalToConstant: 10)
        }
        
        self.emojiListView.translatesAutoresizingMaskIntoConstraints = false
        self.emojiListView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.fakeInputView.alpha = 1.0
        self.fakeInputView.backgroundColor = .red
        
        self.emojiListView.setupStyling()
    }
}

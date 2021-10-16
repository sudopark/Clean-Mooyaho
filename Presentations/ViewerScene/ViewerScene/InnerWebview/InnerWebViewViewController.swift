//
//  InnerWebViewViewController.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - InnerWebViewViewController

public final class InnerWebViewViewController: BaseViewController, InnerWebViewScene {
    
    private let toolBar = InnerWebViewBottomToolBar()
    private let bottomBackView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    private let webView = WKWebView()
    
    let viewModel: InnerWebViewViewModel
    
    public init(viewModel: InnerWebViewViewModel) {
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

extension InnerWebViewViewController {
    
    private func bind() {
     
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindScrollView()
            })
            .disposed(by: self.disposeBag)
        
        let url = URL(string: "https://www.naver.com")
        let request = URLRequest(url: url!)
        self.webView.load(request)
    }
    
    private func bindScrollView() {
        
        self.webView.scrollView.rx.contentOffset
            .map { $0.y }
            .distinctUntilChanged()
            .throttle(.milliseconds(50), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] y in
                self?.toolBar.updateToolbarPosition(by: y)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension InnerWebViewViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(webView)
        webView.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.view.addSubview(toolBar)
        toolBar.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: InnerWebViewBottomToolBar.Metric.height)
        }
        let toolBarBottomConstraint = toolBar.topAnchor
            .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                        constant: -InnerWebViewBottomToolBar.Metric.height)
        toolBarBottomConstraint.isActive = true
        toolBar.setupLayout()
        toolBar.bottomOffsetConstraint = toolBarBottomConstraint
        
        self.view.addSubview(bottomBackView)
        bottomBackView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.topAnchor.constraint(equalTo: toolBar.topAnchor)
        }
        
        self.view.bringSubviewToFront(toolBar)
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.webView.scrollView.contentInset = .init(top: 0, left: 0,
                                                     bottom: InnerWebViewBottomToolBar.Metric.height,
                                                     right: 0)
        
        self.toolBar.setupStyling()
    }
}

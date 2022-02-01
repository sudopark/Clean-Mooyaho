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
import Prelude

import CommonPresenting


// MARK: - InnerWebViewViewController

public final class InnerWebViewViewController: BaseViewController, InnerWebViewScene {
    
    private let toolBar = InnerWebViewBottomToolBar()
    private let bottomBackView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    private let headerView = BaseHeaderView()
    private let pullGuideView = PullGuideView()
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
        self.viewModel.prepareLinkData()
    }
}

// MARK: - bind

extension InnerWebViewViewController {
    
    private func bind() {
        
        self.viewModel.startLoadWebPage
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] url in
                self?.loadWebPage(address: url)
            })
            .disposed(by: self.disposeBag)
     
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindScrollView()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.urlPageTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(self.toolBar.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.bindWebView()
        
        self.toolBar.safariButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.openPageInSafari()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isEditable ? self.bindEditing() : self.toolBar.hideEditingViews()
        self.viewModel.isJumpable ? self.bindJumpping() : self.toolBar.hideJumping()
        
        self.headerView.closeButton?.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindEditing() {
        
        self.viewModel.isRed
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isRed in
                let imageName = isRed ? "checkmark.circle.fill" : "checkmark.circle"
                self?.toolBar.readMarkButton.setImage(UIImage(systemName: imageName), for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.hasMemo
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] has in
                let imageName = has ? "note.text" : "note.text.badge.plus"
                self?.toolBar.memoButton.setImage(UIImage(systemName: imageName), for: .normal)
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.readMarkButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleMarkAsRed()
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.memoButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.editMemo()
            })
            .disposed(by: self.disposeBag)
        
        Observable.merge(self.toolBar.editButton.rx.throttleTap(),
                         self.toolBar.titleLabel.rx.addTapgestureRecognizer().map { _ in })
            .subscribe(onNext: { [weak self] in
                self?.viewModel.editReadLink()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindJumpping() {
        self.toolBar.jumpFolderButton.isHidden = false
        self.toolBar.jumpFolderButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.jumpToCollection()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func loadWebPage(address: String) {
        guard let url = URL(string: address) else { return }
        let urlRequest = URLRequest(url: url)
        self.webView.load(urlRequest)
    }
    
    private func bindScrollView() {
        
        let scrollY = self.webView.scrollView.rx.contentOffset.map { $0.y }.asObservable()
        let scrollChanges = Observable.zip(scrollY, scrollY.skip(1))
            .map { (previous, current) in current - previous }
        let isScrollDown = scrollChanges.map { $0 >= 0 }
        
        let threshold = InnerWebViewBottomToolBar.Metric.height
        let filterWhenUserDragging: (Bool) -> Bool? = { [weak self] isDown in
            guard let self = self else { return nil }
            let isAnimatable = self.webView.scrollView.isDragging && self.webView.scrollView.contentOffset.y > threshold
            return isAnimatable ? isDown : nil
        }
        
        isScrollDown
            .compactMap(filterWhenUserDragging)
            .distinctUntilChanged()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isDown in
                self?.toolBar.hideOrShowToolbarWithAnimation(isDown)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - handling webView delegates

extension InnerWebViewViewController: WKNavigationDelegate {
    
    private func bindWebView() {
        self.webView.rx.observeWeakly(Double.self, "estimatedProgress", options: .new)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] progress in
                self?.toolBar.updateLoadingStatus(progress)
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.backButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                guard self?.webView.canGoBack == true else { return }
                self?.webView.goBack()
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.nextButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                guard self?.webView.canGoForward == true else { return }
                self?.webView.goForward()
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.refreshButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                guard self?.webView.isLoading == false else { return }
                self?.webView.reload()
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.safariButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.openPageInSafari()
            })
            .disposed(by: self.disposeBag)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let forwardCount = self.webView.backForwardList.forwardList.count
        let backwardCount = self.webView.backForwardList.backList.count
        self.toolBar.updateNavigationButton(isBack: true, enable: backwardCount > 0)
        self.toolBar.updateNavigationButton(isBack: false, enable: forwardCount > 0)
    }
}

// MARK: - setup presenting

extension InnerWebViewViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(headerView)
        headerView.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 16)
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
        }
        headerView.setupLayout()
        headerView.setupMainContentView(pullGuideView, onlyWhenCloseNotNeed: true)
        pullGuideView.setupLayout()
        
        self.view.addSubview(webView)
        webView.autoLayout.active(with: self.view) {
            $0.topAnchor.constraint(equalTo: headerView.bottomAnchor)
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
        
        self.headerView.setupStyling()
        self.pullGuideView.setupStyling()
        
        self.webView.scrollView.contentInset = .init(top: 0, left: 0,
                                                     bottom: InnerWebViewBottomToolBar.Metric.height,
                                                     right: 0)
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.navigationDelegate = self
        self.webView.backgroundColor = uiContext.colors.appBackground
        
        self.toolBar.setupStyling()
    }
}

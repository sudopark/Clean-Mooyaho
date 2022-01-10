//
//  MainViewController.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - MainScene

public protocol MainSceneInteractable: MainSlideMenuSceneListenable, ReadCollectionNavigateListenable, SharedCollectionInfoDialogSceneListenable, IntegratedSearchSceneListenable & SuggestReadSceneListenable & InnerWebViewSceneListenable & RecoverAccountSceneListenable {
    
    func showSharedReadCollection(_ collection: SharedReadCollection)
    
    func showRemindDetail(_ itemID: String)
}

public protocol MainScene: Scenable {
    
    var interactor: MainSceneInteractable? { get }
    var childContainerView: UIView { get }
    var childBottomSlideContainerView: UIView { get }
}


// MARK: - MainViewController

public final class MainViewController: BaseViewController, MainScene {
    
    private let mainView = MainView()
    private let viewModel: MainViewModel
    
    public var interactor: MainSceneInteractable? {
        return self.viewModel as? MainSceneInteractable
    }
    
    public var childContainerView: UIView {
        return self.mainView.mainContainerView
    }
    
    public var childBottomSlideContainerView: UIView {
        return self.mainView.bottomSlideEmbedView
    }
    
    private var tipsView: EasyTipView?
    
    public init(viewModel: MainViewModel) {
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
        self.viewModel.setupSubScenes()
        self.bind()
        self.viewModel.checkHasSomeSuggestAddItem()
        self.viewModel.checkMemberActivatedState()
    }

}

// MARK: - bind

extension MainViewController {
    
    private func bind() {
        
        self.bindProfileSection()
        self.bindAddItem()
        self.bindBottomBarToolButtons()
        self.bindShareCollectionRootSwitching()
        self.bindSearch()
        self.bindShowAddItemGuide()
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindBottomSlideScroll()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindProfileSection() {
        
        self.mainView.profileImageView.rx
            .addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.requestOpenSlideMenu()
            })
            .disposed(by: self.disposeBag)
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindMemberProfileImage()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindAddItem() {
        
        self.mainView.addItemButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.tipsView?.dismiss()
                self?.viewModel.requestAddNewItem()
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.floatingBottomButtonContainerView.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.mainView.floatingBottomButtonContainerView.hideButton()
                self?.viewModel.requestAddNewItemUsingURLInClipBoard()
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.floatingBottomButtonContainerView.rx.closeTap()
            .subscribe(onNext: { [weak self] in
                self?.mainView.floatingBottomButtonContainerView.hideButton()
            })
            .disposed(by: self.disposeBag)
        
        UIContext.currentAppStatus
            .subscribe(onNext: { [weak self] state in
                guard state == .forground else { return }
                self?.viewModel.checkHasSomeSuggestAddItem()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.showAddItemInUsingURLInClipBoard
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] url in
                self?.mainView.floatingBottomButtonContainerView.showButton(with: url)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindBottomBarToolButtons() {
        
        self.mainView.shrinkButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleIsReadItemShrinkMode()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isReadItemShrinkModeOn
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isOn in
                self?.updateIsShrinkModeOn(isOn)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindShareCollectionRootSwitching() {
        self.viewModel.currentCollectionRoot
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] root in
                self?.mainView.updateBottomToolbar(by: root)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isAvailToAddItem
            .asDriver(onErrorDriveWith: .never())
            .drive(self.mainView.addItemButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.mainView.sharedRootCollectionView
            .bindOwnerInfo(self.viewModel.currentSharedCollectionOwnerInfo)
            .disposed(by: self.disposeBag)
        
        self.viewModel.shareStatus
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] status in
                self?.mainView.updateShareStatus(status)
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.shareButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleShareStatus()
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.exitButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.returnToMyReadCollections()
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.sharedRootCollectionView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.showSharedCollectionDetail()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindSearch() {
        self.mainView.bottomSearchBarView.rx.didEditBegin
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mainView.expandBottomViewForSearchWithAnimation()
                self.updateBottomSlideOffsetIfNeed(show: true)
                self.viewModel.didUpdateBottomSearchAreaShowing(isShow: true)
            })
            .disposed(by: self.disposeBag)

        let inputText = Observable.merge(self.mainView.bottomSearchBarView.rx.text,
                                         self.mainView.bottomSearchBarView.rx.clear.map { "" })
        inputText
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.didUpdateSearchText(text)
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.bottomSearchBarView.rx.didEnterEnd
            .subscribe(onNext: { [weak self] in
                guard let text = self?.mainView.bottomSearchBarView.textField.text else { return }
                self?.view.endEditing(true)
                self?.viewModel.didRequestSearch(with: text)
            })
            .disposed(by: self.disposeBag)
        
        let cancelByButton = self.mainView.cancelSearchButton.rx.throttleTap()
        let cancelByOuterTrigger = self.viewModel.isSearchFinished
        Observable.merge(cancelByButton, cancelByOuterTrigger)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.finishSearchInput()
            })
            .disposed(by: self.disposeBag)

        self.viewModel.isIntegratedSearching
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isSearching in
                self?.mainView.bottomSearchBarView.updateIsLoading(isSearching)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func finishSearchInput() {
        self.mainView.shrinkBottomViewWithAnimation()
        self.mainView.bottomSearchBarView.clearInput()
        self.mainView.bottomSearchBarView.textField.resignFirstResponder()
        self.updateBottomSlideOffsetIfNeed(show: false)
        self.viewModel.didUpdateBottomSearchAreaShowing(isShow: false)
    }
    
    private func bindMemberProfileImage() {
        self.viewModel.currentMemberProfileImage
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] source in
                self?.mainView.profileImageView.setupImage(using: source)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateIsShrinkModeOn(_ newValue: Bool) {
        self.mainView.shrinkButton.backgroundColor = newValue
            ? self.uiContext.colors.defaultButtonOn
            : self.uiContext.colors.defaultButtonOff
    }
    
    private func bindShowAddItemGuide() {
        
        self.rx.viewDidAppear.take(1)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showAddItemGuideIfNeed()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func showAddItemGuideIfNeed() {
        
        guard self.viewModel.isNeedShowAddItemGuide() else { return }
        
        let message = "Click the Next button to add a new reading list or archive an item to read.".localized
        let preference = EasyTipView.Preferences()
            |> \.drawing.backgroundColor .~ self.uiContext.colors.accentColor
        |> \.drawing.arrowPosition .~ .bottom
        
        self.tipsView = EasyTipView(text: message, preferences: preference)
        self.tipsView?.show(animated: true, forView: self.mainView.addItemButton)
    }
}

// MARK: - handle pangestures

extension MainViewController {
    
    private var safeAreaBotomInset: CGFloat { UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 }
    private var bottomSlideMinOffset: CGFloat {
        let additionalMargin: CGFloat = self.safeAreaBotomInset == 0 ? 20 : 0
        return 60 + additionalMargin
    }
    private var bottomSlideMaxOffset: CGFloat { self.mainView.bottomSlideContainerView.frame.height-20 }
    
    typealias UpdateBottomOffsetParam = (offset: CGFloat, animationDuration: TimeInterval?)
    
    private func newOffsetByPangestureDy(_ pangesture: UIPanGestureRecognizer) -> Observable<UpdateBottomOffsetParam> {
        
        let scrollChanged = pangesture.rx.event.filter{ $0.state == .changed }
        return scrollChanged
            .calculateDy(in: self.view)
            .distinctUntilChanged()
            .compactMap{ [weak self] dy -> UpdateBottomOffsetParam? in
                guard let self = self else { return nil }
                return (-self.mainView.bottomSlideBottomOffsetConstraint.constant - dy, nil)
            }
            .do(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
    }
    
    private func newOffsetByPangestureEnd(_ pangesture: UIPanGestureRecognizer) -> Observable<UpdateBottomOffsetParam> {
        let scrollDidEnd = pangesture.rx.event.filter{ $0.state == .cancelled || $0.state == .ended }
        return scrollDidEnd.velocity(in: self.view)
            .compactMap { [weak self] velocity -> UpdateBottomOffsetParam? in
                guard let self = self,
                      let shouldMoveTo = self.findNearestSticyPosition(velocity) else { return nil }
                let curentOffset = self.mainView.bottomSlideBottomOffsetConstraint.constant
                let moveDistance = curentOffset - shouldMoveTo
                let animationDuration = max(0.08, min(0.3, TimeInterval(abs(moveDistance/velocity))))
                return (shouldMoveTo, animationDuration)
            }
    }
    
    private func bindBottomSlideScroll() {
        
        let pangesture = UIPanGestureRecognizer()
        self.mainView.bottomSlideContainerView.addGestureRecognizer(pangesture)
        Observable
            .merge(self.newOffsetByPangestureDy(pangesture), self.newOffsetByPangestureEnd(pangesture))
            .subscribe(onNext: { [weak self] params in
                guard let self = self else { return }
                self.updateBottomSlideOffset(params.offset, withAnimation: params.animationDuration)
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.bottomSlideBottomOffsetConstraint.constant = -self.bottomSlideMinOffset
    }
    
    private func updateBottomSlideOffsetIfNeed(show: Bool) {
        guard show else {
            self.updateBottomSlideOffset(self.bottomSlideMinOffset, withAnimation: 0.55, withBounce: false)
            return
        }
        let threshold = self.bottomSlideMaxOffset * 3 / 5
        guard -self.mainView.bottomSlideBottomOffsetConstraint.constant <= threshold else { return }
        self.updateBottomSlideOffset(self.bottomSlideMaxOffset, withAnimation: 0.7, withBounce: false)
    }
    
    private func updateBottomSlideOffset(_ invertedNewOffset: CGFloat,
                                         withAnimation duration: TimeInterval? = nil,
                                         withBounce: Bool = true) {
        let newOffset = -min(self.bottomSlideMaxOffset, max(self.bottomSlideMinOffset, invertedNewOffset))
        self.mainView.bottomSlideBottomOffsetConstraint.constant = newOffset

        guard let duration = duration else { return }
        
        let damping: Double = withBounce ? 0.7 : 1.0
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func findNearestSticyPosition(_ dyVelocity: CGFloat) -> CGFloat? {
        
        let threshold: CGFloat = 700
        guard abs(dyVelocity) >= threshold else { return nil }
        
        let pointClose: CGFloat = self.bottomSlideMinOffset
        let pointFullOpen = self.bottomSlideMaxOffset
        let pointHalfOpen = (self.bottomSlideMaxOffset-60)/5 * 3
        let currentOffset = -self.mainView.bottomSlideBottomOffsetConstraint.constant
        
        let isMovingUp = dyVelocity < 0
        switch isMovingUp {
//        case true where currentOffset > pointHalfOpen:
        case true:
            return pointFullOpen
            
//        case true:
//            return pointHalfOpen
            
//        case false where currentOffset > pointHalfOpen:
//            return pointHalfOpen
            
        case false:
            return pointClose
        }
    }
}

// MARK: - setup presenting

extension MainViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.mainView)
        mainView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
        }
        mainView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.mainView.setupStyling()
    }
}


private extension Observable where Element == UIPanGestureRecognizer {
    
    func calculateDy(in view: UIView) -> Observable<CGFloat> {
        return self.compactMap { [weak view] gestureRecognizer -> CGFloat? in
            guard let view = view else { return nil }
            let dy = gestureRecognizer.translation(in: view).y
            gestureRecognizer.setTranslation(.zero, in: view)
            return dy
        }
    }
    
    func velocity(in view: UIView) -> Observable<CGFloat> {
        return self.compactMap { [weak view] gestureRecognizer -> CGFloat? in
            guard let view = view else { return nil }
            return gestureRecognizer.velocity(in: view).y
        }
    }
}

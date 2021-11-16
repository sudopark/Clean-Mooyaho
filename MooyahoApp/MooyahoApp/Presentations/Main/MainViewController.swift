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

import Domain
import CommonPresenting


// MARK: - MainScene

public protocol MainSceneInteractable: SignInSceneListenable, MainSlideMenuSceneListenable, ReadCollectionNavigateListenable {
    
    func showSharedReadCollection(_ collection: SharedReadCollection)
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
        return self.mainView.bottomSlideContainerView
    }
    
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
    }

}

// MARK: - bind

extension MainViewController {
    
    private func bind() {
        
        self.mainView.profileImageView.rx
            .addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.requestOpenSlideMenu()
            })
            .disposed(by: self.disposeBag)
        
        self.mainView.addItemButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
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
        
        self.mainView.shrinkButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleIsReadItemShrinkMode()
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
        
        self.viewModel.isReadItemShrinkModeOn
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isOn in
                self?.updateIsShrinkModeOn(isOn)
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindBottomSlideScroll()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindMemberProfileImage()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.currentCollectionRoot
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] root in
                self?.mainView.updateBottomToolbar(by: root)
            })
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
            ? self.uiContext.colors.secondaryAccentColor
            : self.uiContext.colors.raw.lightGray
    }
}

// MARK: - handle pangestures

extension MainViewController {
    
    private var bottomSlideMinOffset: CGFloat { 60 }
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
        
        let newBottonConstraint = BehaviorSubject<UpdateBottomOffsetParam?>(value: nil)
        
        Observable
            .merge(self.newOffsetByPangestureDy(pangesture), self.newOffsetByPangestureEnd(pangesture))
            .bind(to: newBottonConstraint)
            .disposed(by: self.disposeBag)
        
        newBottonConstraint
            .subscribe(onNext: { [weak self] params in
                guard let self = self, let params = params else { return }
                self.updateBottomSlideOffset(params.offset, withAnimation: params.animationDuration)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateBottomSlideOffset(_ invertedNewOffset: CGFloat, withAnimation duration: TimeInterval? = nil) {
        let newOffset = -min(self.bottomSlideMaxOffset, max(self.bottomSlideMinOffset, invertedNewOffset))
        self.mainView.bottomSlideBottomOffsetConstraint.constant = newOffset
        
        guard let duration = duration else { return }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
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
        case true where currentOffset > pointHalfOpen:
            return pointFullOpen
            
        case true where currentOffset > pointClose:
            return pointHalfOpen
            
        case false where currentOffset > pointHalfOpen:
            return pointHalfOpen
            
        case false where currentOffset > pointClose:
            return pointClose
            
        default: return nil
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

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

import CommonPresenting


// MARK: - MainScene

public protocol MainScene: Scenable {
    
    var childContainerView: UIView { get }
    var childBottomSlideContainerView: UIView { get }
}


// MARK: - MainViewController

public final class MainViewController: BaseNavigationController, MainScene {
    
    private let mainView = MainView()
    private let viewModel: MainViewModel
    
    public var childContainerView: UIView {
        return self.mainView.mapContainerView
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
    }

}

// MARK: - bind

extension MainViewController {
    
    private func bind() {
        
        self.mainView.profileView.rx
            .addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.openSlideMenu()
            })
            .disposed(by: self.dispsoseBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindBottomSlideScroll()
            })
            .disposed(by: self.dispsoseBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindMemberProfileImage()
            })
            .disposed(by: self.dispsoseBag)
    }
    
    private func bindMemberProfileImage() {
        self.viewModel.currentMemberProfileImage
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] source in
                self?.mainView.profileView.setupImage(using: source)
            })
            .disposed(by: self.dispsoseBag)
    }
}

// MARK: - handle pangestures

extension MainViewController {
    
    private var bottomSlideMinOffset: CGFloat { 80 }
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
            .disposed(by: self.dispsoseBag)
        
        newBottonConstraint
            .subscribe(onNext: { [weak self] params in
                guard let self = self, let params = params else { return }
                self.updateBottomSlideOffset(params.offset, withAnimation: params.animationDuration)
            })
            .disposed(by: self.dispsoseBag)
        
        let shouldHideFloatings = newBottonConstraint.compactMap{ $0?.offset }
            .compactMap { [weak self] offset -> Bool? in
                guard let self = self else { return nil }
                let threshold = self.view.frame.height - 150
                return offset >= threshold
            }
        shouldHideFloatings
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] hide in
                self?.updateFloatingButtonVisibilities(hide)
            })
            .disposed(by: self.dispsoseBag)
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
    
    private func updateFloatingButtonVisibilities(_ shouldHide: Bool) {
        
        let changeAlphaTo: CGFloat = shouldHide ? 0.0 : 1.0
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mainView.newHoorayButton.alpha = changeAlphaTo
            self?.mainView.topFloatingButtonContainerView.alpha = changeAlphaTo
        })
    }
}

// MARK: - setup presenting

extension MainViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(self.mainView)
        mainView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
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

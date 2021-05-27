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
}


// MARK: - MainViewController

public final class MainViewController: BaseNavigationController, MainScene {
    
    private let mainView = MainView()
    private let viewModel: MainViewModel
    
    public var childContainerView: UIView {
        return self.mainView.mapContainerView
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
        self.viewModel.viewDidLoaded()
        self.bind()
    }

}

// MARK: - bind

extension MainViewController {
    
    private func bind() {
        
        self.mainView.navigationBarView.profileImageView.rx
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
    }
}

// MARK: - handle pangestures

extension MainViewController {
    
    private var bottomSlideMinOffset: CGFloat { 80 }
    private var bottomSlideMaxOffset: CGFloat { self.mainView.bottomSlideContainerView.frame.height-20 }
    
    private func bindBottomSlideScroll() {
        
        let pangesture = UIPanGestureRecognizer()
        self.mainView.bottomSlideContainerView.addGestureRecognizer(pangesture)
        
        let scrollChanged = pangesture.rx.event.filter{ $0.state == .changed }
        
        scrollChanged
            .calculateDy(in: self.view)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] dy in
                guard let self = self else { return }
                let invertedNewOffset = -self.mainView.bottomSlideBottomOffsetConstraint.constant - dy
                self.updateBottomSlideOffset(invertedNewOffset)
            })
            .disposed(by: self.dispsoseBag)
        
        let scrollDidEnd = pangesture.rx.event.filter{ $0.state == .cancelled || $0.state == .ended }
        scrollDidEnd
            .velocity(in: self.view)
            .subscribe(onNext: { [weak self] velocity in
                guard let self = self,
                      let shouldMoveTo = self.findNearestSticyPosition(velocity) else { return }
                let curentOffset = self.mainView.bottomSlideBottomOffsetConstraint.constant
                let moveDistance = curentOffset - shouldMoveTo
                let animationDuration = max(0.08, min(0.3, TimeInterval(abs(moveDistance/velocity))))
                self.updateBottomSlideOffset(shouldMoveTo, withAnimation: animationDuration)
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
        
        self.view.backgroundColor = self.context.colors.appBackground
        
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

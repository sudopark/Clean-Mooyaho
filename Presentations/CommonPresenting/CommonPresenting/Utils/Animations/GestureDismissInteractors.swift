//
//  GestureDismissInteractors.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit

import RxSwift


// MARK: - PangestureDismissalInteractor

public class PangestureDismissalInteractor: UIPercentDrivenInteractiveTransition {
    
    var hasStarted = false
    var shouldFinish = false
    public weak var viewController: UIViewController?
    
    public func addDismissPangesture(_ targetView: UIView,
                                     dismissController: @escaping () -> Void) -> Disposable {
        return Disposables.create()
    }
}


// MARK: - RightSwipePangestureDismissalInteractor

public final class RightSwipePangestureDismissalInteractor: PangestureDismissalInteractor {
    
    public override func addDismissPangesture(_ targetView: UIView,
                                              dismissController: @escaping () -> Void) -> Disposable {
        
        let gestureRecognizer = UIPanGestureRecognizer()
        targetView.addGestureRecognizer(gestureRecognizer)
        
        return gestureRecognizer.rx.event
            .bind(onNext: { [weak self] gesture in
                self?.handleLeftDismissPangesture(gesture, dismissController: dismissController)
            })
    }
}

extension RightSwipePangestureDismissalInteractor {
    
    private func handleLeftDismissPangesture(_ gesture: UIPanGestureRecognizer, dismissController: () -> Void) {
        
        let threshold: CGFloat = 0.4
        let transition = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        let overThresHold: (CGFloat, CGPoint) -> Bool = { percent, velocity in
            return percent > threshold || velocity.x >= 1_200
        }
        
        var percent = transition.x / UIScreen.main.bounds.width
        percent = min(1, percent)
        percent = max(0, percent)
        
        switch gesture.state {
        case .began:
            self.hasStarted = true
            self.shouldFinish = false
            dismissController()
            
        case .changed:
            self.shouldFinish = overThresHold(percent, velocity)
            self.update(percent)
            
        case .cancelled:
            self.hasStarted = false
            self.shouldFinish = overThresHold(percent, velocity)
            self.cancel()
            
        case .ended:
            self.hasStarted = false
            self.shouldFinish ? self.finish() : self.cancel()
            
        default: break
        }
    }
}


// MARK: - BottomPullPangestureDismissalInteractor

public final class BottomPullPangestureDismissalInteractor: PangestureDismissalInteractor {
    
    public override func addDismissPangesture(_ targetView: UIView,
                                              dismissController: @escaping () -> Void) -> Disposable {
        
        let gestureRecognizer = UIPanGestureRecognizer()
        gestureRecognizer.delegate = self
        targetView.addGestureRecognizer(gestureRecognizer)

        return gestureRecognizer.rx.event
            .bind(onNext: { [weak self] gesture in
                self?.handleBottomDismissPangesture(gesture, dismissController: dismissController)
            })
    }
}

extension BottomPullPangestureDismissalInteractor: UIGestureRecognizerDelegate {
    
    private func handleBottomDismissPangesture(_ gesture: UIPanGestureRecognizer, dismissController: () -> Void) {
        
        let transition = gesture.translation(in: gesture.view)
        
        let safeAreaBottomPadding = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let totalLength = (gesture.view?.frame.height ?? UIScreen.main.bounds.height) - safeAreaBottomPadding
        var percent = transition.y / totalLength
        percent = min(1, percent)
        percent = max(0, percent)
        
        switch gesture.state {
        case .began:
            self.hasStarted = true
            dismissController()
            
        case .changed:
            self.shouldFinish = percent > 0.3
            self.update(percent)
            
        case .cancelled:
            self.hasStarted = false
            self.cancel()
            
        case .ended:
            self.hasStarted = false
            self.shouldFinish ? self.finish() : self.cancel()
            
        default: break
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        
        let isControllTapped = touch.view is UIControl
        guard isControllTapped == false else {
            return false
        }
        
        guard self.isNotTouchTableView(touch) else {
            return false
        }
        
        guard let view = viewController?.view else { return false }
        
        let scrollView = self.findScrollView(in: view, touch: touch)
        guard let contentOffsetY = scrollView?.contentOffset.y else { return true }
        return contentOffsetY <= 20
    }
    
    private func isNotTouchTableView(_ touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        switch view {
        case _ where view is UITableViewCell: return false
        case _ where view is UITableView: return false
        case _ where view.superview is UITableViewCell: return false
        default: return true
        }
    }
    
    private func findScrollView(in view: UIView, touch: UITouch) -> UIScrollView? {
        
        let location = touch.location(in: view)
        if let scrollView = view as? UIScrollView, view.frame.contains(location) {
           return scrollView
        }
        
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView, subview.frame.contains(location) {
                return scrollView
            } else {
                guard let scrollView = findScrollView(in: subview, touch: touch) else {
                    continue
                }
                return scrollView
            }
        }
        return nil
    }
}

// MARK: - PangestureDismissableScene

@MainActor
public protocol PangestureDismissableScene {
    
    func setupDismissGesture(_ dismissInteractor: PangestureDismissalInteractor)
}

extension PangestureDismissableScene where Self: BaseViewController {
    
    public func setupDismissGesture(_ dismissInteractor: PangestureDismissalInteractor) {
        
        dismissInteractor.viewController = self
        
        let bindDismissInteractor: () -> Void = { [weak self, weak dismissInteractor] in
            guard let self = self, let interactor = dismissInteractor else { return }
            let bottomSlide = self as? BottomSlideViewSupporatble
            let targetView: UIView = bottomSlide?.bottomSlideMenuView.panGestureInteractView ?? self.view
            interactor.addDismissPangesture(targetView) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: self.disposeBag)
        }
        
        self.rx.viewDidLayoutSubviews.take(1)
            .map{ _ in }
            .subscribe(onNext: bindDismissInteractor)
            .disposed(by: self.disposeBag)
    }
}

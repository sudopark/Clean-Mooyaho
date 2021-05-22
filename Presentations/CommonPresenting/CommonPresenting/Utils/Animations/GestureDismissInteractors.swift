//
//  GestureDismissInteractors.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit

import RxSwift


public protocol PangestureDismissableScene {
    
    func setupDismissGesture(_ dismissInteractor: PangestureDismissalInteractor)
}

extension PangestureDismissableScene where Self: BaseViewController {
    
    public func setupDismissGesture(_ dismissInteractor: PangestureDismissalInteractor) {
        
        let bindDismissInteractor: () -> Void = { [weak self, weak dismissInteractor] in
            guard let self = self, let interactor = dismissInteractor else { return }
            interactor.addLeftDismissPangesture(self.view) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: self.disposeBag)
        }
        
        self.rx.viewDidLoad
            .map{ _ in }
            .subscribe(onNext: bindDismissInteractor)
            .disposed(by: self.disposeBag)
    }
}


public final class PangestureDismissalInteractor: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    weak var viewController: UIViewController?
    var hasStarted = false
    var shouldFinish = false
}

extension PangestureDismissalInteractor {
    public func addLeftDismissPangesture(_ targetView: UIView, dismissController: @escaping () -> Void) -> Disposable {
        
        let gestureRecognizer = UIPanGestureRecognizer()
        targetView.addGestureRecognizer(gestureRecognizer)
        
        return gestureRecognizer.rx.event
            .bind(onNext: { [weak self] gesture in
                self?.handleLeftDismissPangesture(gesture, dismissController: dismissController)
            })
    }
    
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
